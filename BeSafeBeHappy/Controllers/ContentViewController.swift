import UIKit


class ContentViewController: UIViewController {
    
    var callback: ((Folder?) -> Void?)?
    
    var dataSourceFolder: Folder?
    
    private lazy var photosCollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ContentCollectionViewCell.self,
                                forCellWithReuseIdentifier: ContentCollectionViewCell.identifier)
        return collectionView
    }()
    
    private lazy var plusButton = {
        let button = AdaptiveButton(title: "Добавить новое фото",
                                    image: UIImage(systemName: "plus.circle") ?? UIImage(),
                                    fontSize: Constants.FontSizes.medium)
        button.addTarget(self, action: #selector(showAddingPhotoScreen(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentView = {
        let view = UIView()
        return view
    }()
    
    private var collectionViewDataSource = [CellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        dataSourceFolder
        dataSourceFolder = UserDefaults.standard.object(Folder.self, forKey: Constants.UserDefaultsKeys.contentList)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let dataSourceFolder {
            UserDefaults.standard.set(encodable: dataSourceFolder, forKey: Constants.UserDefaultsKeys.contentList)
        }
        callback?(dataSourceFolder)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: photosCollectionView)
        if let indexPath = photosCollectionView.indexPathForItem(at: location) {
            let item = collectionViewDataSource[indexPath.item]
            if item.isAlbum {
                let realFolder = searchChosenFolder(from: item)
                createNewContentListScreen(folder: realFolder)
            } else {
                showImageEditingScreen(imageName: item.imageName)
            }
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        photosCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = photosCollectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell
            cell?.wobble()
        }
    }
    
    @objc func showAddingPhotoScreen(_ sender: Any) {
        let newPhotoController = NewPhotoViewController()
        newPhotoController.delegate = self
        navigationController?.pushViewController(newPhotoController, animated: true)
    }
    
    @objc func addPhoto(_ sender: UIBarButtonItem) {
        showAddingPhotoScreen(sender)
    }
    
    @objc func addFolder(_ sender: UIBarButtonItem) {
        let alertTextField = UITextField()
        
        showAlertWithTextField(alertTitle: "Добавить папку",
                               messageTitle: "Имя папки",
                               alertStyle: .alert,
                               firstButtonTitle: "Ok",
                               firstAlertActionStyle: .default,
                               usersTextField: alertTextField) { [weak self] text in
            let newFolder = Folder(insideFolders: nil, photosList: nil, title: text)
            self?.addNewFolder(folder: newFolder)
        }
    }
    
    private func addNewFolder(folder: Folder) {
        if let dataSourceInsideFolder = dataSourceFolder?.insideFolders {
            dataSourceFolder?.insideFolders?.append(folder)
        } else {
            //if first folder added
            dataSourceFolder?.insideFolders = [folder]
        }
        collectionViewDataSource.append(makeFolderCellModel(folder: folder))
        photosCollectionView.reloadData()
    }
    
    private func setupContentScreenTitle() {
        //is First сontent screen?
        if dataSourceFolder?.title ==  Constants.Text.galeryTitle {
            navigationItem.hidesBackButton = true
        }
        
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "photo"),
                                                                                            style: .plain,
                                                                                            target: self,
                                                                                            action: #selector(addPhoto(_:))),
                                                                            UIBarButtonItem(image: UIImage(systemName: "folder.badge.plus"),
                                                                                            style: .plain,
                                                                                            target: self,
                                                                                            action: #selector(addFolder(_:)))
        ]
        title = dataSourceFolder?.title
    }
    
    
    private func setupUI() {
        setupContentScreenTitle()
        addSubviews()
        setupConstraints()
        configureCollectionDataSource()
        addGestureRecognizer()
    }
    
    private func configureCollectionDataSource() {
        dataSourceFolder?.insideFolders?.forEach { folder  in
            let cellModel = CellModel(title: folder.title,
                                      imageName: "",
                                      isAlbum: true)
            collectionViewDataSource.append(cellModel)
        }
        
        dataSourceFolder?.photosList?.forEach { photo in
            let cellModel = CellModel(title: photo.imageName,
                                      imageName: photo.path,
                                      isAlbum: false)
            collectionViewDataSource.append(cellModel)
        }
    }
    
    private func makePhotoCellModel(photoModel: PhotoMetaData) -> CellModel {
        CellModel(title: photoModel.imageName,
                  imageName: photoModel.path,
                  isAlbum: false)
        
    }
    
    private func makeFolderCellModel(folder: Folder) -> CellModel {
        CellModel(title: folder.title,
                                  imageName: "",
                                  isAlbum: true)
    }
    
    private func addSubviews() {
        view.addSubview(contentView)
        contentView.addSubview(photosCollectionView)
        view.addSubview(plusButton)
    }
    
    func addGestureRecognizer() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        photosCollectionView.addGestureRecognizer(tap)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPress.minimumPressDuration = 1
        longPress.delegate = self
        photosCollectionView.addGestureRecognizer(longPress)
                                                
    }
    
    func showImageEditingScreen(imageName: String) {
        let newPhotoController = NewPhotoViewController()
        newPhotoController.realImageName = imageName
        newPhotoController.delegate = self
        navigationController?.pushViewController(newPhotoController, animated: true)
    }
    
    func createNewContentListScreen(folder: Folder) {
        let newContentScreen = ContentViewController()
        newContentScreen.dataSourceFolder = folder
        newContentScreen.callback = { [weak self] folder in
            self?.callback?(folder)
        }
        navigationController?.pushViewController(newContentScreen, animated: true)
    }
    
    func searchChosenFolder(from cell: CellModel) -> Folder {
        let contentList = dataSourceFolder?.insideFolders
        if let matchingFolder = contentList?.first(where: { $0.title == cell.title}) {
            return matchingFolder
        }
        
        return Folder(insideFolders: nil, photosList: nil, title: "")
    }
}

extension ContentViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.identifier,
                                                            for: indexPath) as? ContentCollectionViewCell else {
            return ContentCollectionViewCell()
        }
        
        cell.configure(model: collectionViewDataSource[indexPath.item])
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let side = (collectionView.frame.width - Constants.Offsets.medium) / 2
        return CGSize(width: side, height: side)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        Constants.Offsets.medium
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        photosCollectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        plusButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-Constants.Offsets.big)
            make.centerX.equalToSuperview()
            make.width.equalTo(Constants.Sizes.MainController.addButtonWidth)
            make.height.equalTo(Constants.Sizes.MainController.addButtonHeight)
        }
    }
}

extension ContentViewController: UIGestureRecognizerDelegate, AddNewPhotoDelegate {
    func addNewPhoto(photoModel: PhotoMetaData) {
        if let dataSourcePhotoList = dataSourceFolder?.photosList {
            dataSourceFolder?.photosList?.append(photoModel)
        } else {
            //if first folder added
            dataSourceFolder?.photosList = [photoModel]
        }
        collectionViewDataSource.append(makePhotoCellModel(photoModel: photoModel))
        photosCollectionView.reloadData()
    }
    
}
