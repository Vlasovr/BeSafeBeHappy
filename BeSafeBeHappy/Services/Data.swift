import UIKit

var imageNameList = [String]()




var secondPhotosListFolder = Array([PhotoMetaData(imageName: "kitty", description: "some kittty", isFavourite: false),
                                    PhotoMetaData(imageName: "ryan", description: "some ryan", isFavourite: false),
                                    PhotoMetaData(imageName: "hamster", description: "some hamster", isFavourite: false),
                                    PhotoMetaData(imageName: "kitty", description: "some kittty", isFavourite: false),
                                    PhotoMetaData(imageName: "ryan", description: "some ryan", isFavourite: false),
                                    PhotoMetaData(imageName: "hamster", description: "some hamster", isFavourite: false),
                                    firstSimplePhoto,
                                    secondSimplePhoto,
                                    thirdSimplePhoto
                                   ].reversed())

var someFolder = [Folder(
                         photosList: secondPhotosListFolder,
                         title: "some folder inside"),
                  Folder(photosList: secondPhotosListFolder, title: "some 2 folder inside")]

var someInsideFolder = Folder(photosList: secondPhotosListFolder, title: "some folder x2 inside")

var firstSimplePhoto = PhotoMetaData(imageName: "ronaldo", description: "some ronaldo", isFavourite: false)
var secondSimplePhoto = PhotoMetaData(imageName: "kitty", description: "some kitty", isFavourite: false)
var thirdSimplePhoto = PhotoMetaData(imageName: "hamster", description: "some hamster", isFavourite: false)
var fourthSimplePhoto = PhotoMetaData(imageName: "ryan", description: "some ryan", isFavourite: false)
var fifthSimplePhoto = PhotoMetaData(imageName: "ronaldo", description: "some ronaldo", isFavourite: false)
var sixthSimplePhoto = PhotoMetaData(imageName: "kitty", description: "some kitty", isFavourite: false)
var seventhSimplePhoto = PhotoMetaData(imageName: "hamster", description: "some hamster", isFavourite: false)
var eightSimplePhoto = PhotoMetaData(imageName: "ryan", description: "some ryan", isFavourite: false)

var photosListFolder = [firstSimplePhoto,
                        secondSimplePhoto,
                        thirdSimplePhoto,
                        fourthSimplePhoto,
                        fifthSimplePhoto,
                        sixthSimplePhoto,
                        seventhSimplePhoto,
                        eightSimplePhoto
                        
]


var someContent = Folder(
                         photosList: photosListFolder,
                         title: "Галерея")
