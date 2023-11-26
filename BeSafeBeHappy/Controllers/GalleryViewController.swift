import UIKit

class GalleryController: UIViewController {
    
    var dataSourceFolder: MainControllerDataSource?
    
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
        let button = AdaptiveButton(title: Constants.Text.GalleryController.plusButtonTitle,
                                    image: UIImage(systemName: Constants.Text.GalleryController.plusButtonImage ) ?? UIImage(),
                                    fontSize: Constants.FontSizes.medium)
        button.addTarget(self, action: #selector(showAddingPhotoScreen(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var contentView = UIView()
    
    private var collectionViewDataSource = [CellModel]() {
        didSet {
            collectionViewDataSource.sort { (model1, model2) -> Bool in
                if model1.isAlbum && !model2.isAlbum {
                    return true
                } else if !model1.isAlbum && model2.isAlbum {
                    return false
                } else {
                    return model1.title < model2.title
                }
            }
            photosCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDataSource()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        saveDataSource()
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: photosCollectionView)
        if let indexPath = photosCollectionView.indexPathForItem(at: location) {
            let item = collectionViewDataSource[indexPath.item]
            
            if item.isAlbum {
                let realFolder = searchChosenFolder(from: item)
                createNewContentListScreen(folder: realFolder)
            } else {
                guard let list = dataSourceFolder?.photoList,
                      let imageIndex = list.firstIndex(where: { $0.imageName == item.title }) else { return }
                let leafletController = LeafletController(photoList: list,
                                                          imageName: item.imageName,
                                                          isFavourite: item.isFavourite ?? false,
                                                          currentImageIndex: imageIndex)
                navigationController?.pushViewController(leafletController, animated: true)
            }
        }
        else {
            stopEditing()
        }
    }
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        photosCollectionView.indexPathsForVisibleItems.forEach { (indexPath) in
            let cell = photosCollectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell
            cell?.startEditingMode()
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
        
        showAlertWithTextField(alertTitle: Constants.Text.GalleryController.alertTitle,
                               messageTitle: Constants.Text.GalleryController.messageTitle,
                               alertStyle: .alert,
                               firstButtonTitle: Constants.Text.GalleryController.firstButtonTitle,
                               firstAlertActionStyle: .default,
                               usersTextField: alertTextField) { [weak self] text in
            let newFolder = Folder(photosList: nil, title: text)
            self?.addNewFolder(folder: newFolder)
        }
    }
    
    private func stopEditing() {
        pauseLayer(layer: photosCollectionView.layer)
        for indexPath in photosCollectionView.indexPathsForVisibleItems {
            if let cell = photosCollectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell {
                cell.endEditingMode()
            }
        }
    }
    
    private func setupDataSource() {
        dataSourceFolder = UserDefaults.standard.object(MainControllerDataSource.self, forKey: Constants.UserDefaultsKeys.mainDataSource)
        
        if dataSourceFolder == nil {
            dataSourceFolder = MainControllerDataSource()
        }
    }
    
    private func saveDataSource() {
        if let dataSourceFolder {
            UserDefaults.standard.set(encodable: dataSourceFolder, forKey: Constants.UserDefaultsKeys.mainDataSource)
        }
    }
    
    private func addNewFolder(folder: Folder) {
        if let dataSourceFolders = dataSourceFolder?.folders {
            dataSourceFolder?.folders?.append(folder)
        } else {
            dataSourceFolder?.folders = [folder]
        }
        
        collectionViewDataSource.append(makeFolderCellModel(folder: folder))
        saveDataSource()
        photosCollectionView.reloadData()
    }
    
    private func setupContentScreenTitle() {
        navigationItem.hidesBackButton = true
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        title = Constants.Text.GalleryController.galleryText
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image:
                                                                UIImage(systemName:
                                                                            Constants.Text.GalleryController.photoImage),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(addPhoto(_:))),
                                              UIBarButtonItem(image: UIImage(systemName: Constants.Text.GalleryController.UIBarButtonItemImage),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(addFolder(_:)))]
    }
    
    
    private func setupUI() {
        setupContentScreenTitle()
        addSubviews()
        setupConstraints()
        configureCollectionDataSource()
        addGestureRecognizer()
    }
    
    private func configureCollectionDataSource() {
        dataSourceFolder?.folders?.forEach { folder  in
            let cellModel = CellModel(title: folder.title,
                                      imageName: "",
                                      isAlbum: true)
            collectionViewDataSource.append(cellModel)
        }
        
        dataSourceFolder?.photoList?.forEach { photo in
            let cellModel = CellModel(title: photo.imageName,
                                      imageName: photo.path,
                                      isFavourite: photo.isFavourite,
                                      isAlbum: false)
            collectionViewDataSource.append(cellModel)
        }
    }
    
    private func makePhotoCellModel(photoModel: PhotoMetaData) -> CellModel {
        CellModel(title: photoModel.imageName,
                  imageName: photoModel.path,
                  isFavourite: photoModel.isFavourite,
                  isAlbum: false)
    }
    
    private func makeFolderCellModel(folder: Folder) -> CellModel {
        CellModel(title: folder.title,
                  imageName: "",
                  isFavourite: false,
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
        longPress.minimumPressDuration = Constants.longPressDuration
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
        let newContentScreen = FolderContentController(sourceFolder: folder)
        navigationController?.pushViewController(newContentScreen, animated: true)
    }
    
    func searchChosenFolder(from cell: CellModel) -> Folder {
        let contentList = dataSourceFolder?.folders
        if let matchingFolder = contentList?.first(where: { $0.title == cell.title}) {
            return matchingFolder
        }
        
        return Folder(photosList: nil, title: "")
    }
}

extension GalleryController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionViewDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentCollectionViewCell.identifier,
                                                            for: indexPath) as? ContentCollectionViewCell else {
            return ContentCollectionViewCell()
        }
        cell.delegate = self
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

extension GalleryController: UIGestureRecognizerDelegate, AddNewPhotoDelegate {
    func addNewPhoto(photoModel: PhotoMetaData) {
        if let dataSourcePhotoList = dataSourceFolder?.photoList {
            dataSourceFolder?.photoList?.append(photoModel)
        } else {
            //if first folder added
            dataSourceFolder?.photoList = [photoModel]
        }
        
        saveDataSource()
        collectionViewDataSource.append(makePhotoCellModel(photoModel: photoModel))
        photosCollectionView.reloadData()
    }
}

extension GalleryController: EditPhotoDelegate {
    func saveDate(photoList: [PhotoMetaData]) {
        dataSourceFolder?.photoList = photoList
        saveDataSource()
    }
}

extension GalleryController: ContentCollectionViewCellDelegate {
    func contentCellDidTapDelete(_ cell: ContentCollectionViewCell) {
        guard let indexPath = photosCollectionView.indexPath(for: cell) else { return }
        
        let isAlbum = collectionViewDataSource[indexPath.item].isAlbum
        let name = collectionViewDataSource[indexPath.item].title
        
        collectionViewDataSource.remove(at: indexPath.item)
        
        if isAlbum {
            if let folderIndex = dataSourceFolder?.folders?.firstIndex(where: { $0.title == name }) {
                dataSourceFolder?.folders?.remove(at: folderIndex)
            }
        } else {
            if let imageIndex = dataSourceFolder?.photoList?.firstIndex(where: { $0.imageName == name }) {
                dataSourceFolder?.photoList?.remove(at: imageIndex)
            }
        }
        
        photosCollectionView.performBatchUpdates{
            photosCollectionView.deleteItems(at: [indexPath])
        }
        
        saveDataSource()
    }
}
