import UIKit

class FolderContentController: UIViewController {
    
    var sourceFolder: Folder
    
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
    
    private var collectionViewDataSource = [CellModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    init(sourceFolder: Folder) {
        self.sourceFolder = sourceFolder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.sourceFolder = Folder(photosList: [], title: "")
        super.init(nibName: nil, bundle: nil)
    }
    
    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: photosCollectionView)
        if let indexPath = photosCollectionView.indexPathForItem(at: location) {
            let item = collectionViewDataSource[indexPath.item]
            guard let list = sourceFolder.photosList else { return }
            showLeaflet(photoList: list,
                        imageName: item.title,
                        isFavourite: item.isFavourite ?? false
            )
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
    
    private func stopEditing() {
        pauseLayer(layer: photosCollectionView.layer)
        for indexPath in photosCollectionView.indexPathsForVisibleItems {
            if let cell = photosCollectionView.cellForItem(at: indexPath) as? ContentCollectionViewCell {
                cell.endEditingMode()
            }
        }
    }
    
    private func setupContentScreenTitle() {
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: Constants.Text.GalleryController.photoImage),
                                                              style: .plain,
                                                              target: self,
                                                              action: #selector(addPhoto(_:))),
        ]
        
        title = sourceFolder.title
    }
    
    private func setupUI() {
        setupContentScreenTitle()
        addSubviews()
        setupConstraints()
        configureCollectionDataSource()
        addGestureRecognizer()
    }
    
    private func configureCollectionDataSource() {
        sourceFolder.photosList?.forEach { photo in
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
    
    private func showLeaflet(photoList: [PhotoMetaData], imageName: String, isFavourite: Bool) {
        guard let imageIndex = photoList.firstIndex(where: { $0.imageName == imageName }) else { return }
        let controller = LeafletController(photoList: photoList,
                                           imageName: imageName,
                                           isFavourite: isFavourite,
                                           currentImageIndex: imageIndex
        )
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FolderContentController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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

extension FolderContentController: UIGestureRecognizerDelegate, AddNewPhotoDelegate {
    func addNewPhoto(photoModel: PhotoMetaData) {
        if let dataSourcePhotoList = sourceFolder.photosList {
            sourceFolder.photosList?.append(photoModel)
        } else {
            //if first folder added
            sourceFolder.photosList = [photoModel]
        }
        collectionViewDataSource.append(makePhotoCellModel(photoModel: photoModel))
        photosCollectionView.reloadData()
    }
}

extension FolderContentController: EditPhotoDelegate {
    func saveDate(photoList: [PhotoMetaData]) {
        sourceFolder.photosList = photoList
    }
}

extension FolderContentController: ContentCollectionViewCellDelegate {
    func contentCellDidTapDelete(_ cell: ContentCollectionViewCell) {
        guard let indexPath = photosCollectionView.indexPath(for: cell) else { return }
    
        let name = collectionViewDataSource[indexPath.item].title
        
        collectionViewDataSource.remove(at: indexPath.item)
        
        if let imageIndex = sourceFolder.photosList?.firstIndex(where: { $0.imageName == name }) {
            sourceFolder.photosList?.remove(at: imageIndex)
        }
        
        photosCollectionView.performBatchUpdates{
            photosCollectionView.deleteItems(at: [indexPath])
        }
    }
}
