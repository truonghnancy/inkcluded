//
//  WacomInkFileFormat.h
//  WacomInk
//
//  Created by Plamen Petkov on 6/22/15.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WacomInkConfig.h"

/**
 The WCMDocumentContentType specifies the type of the resources found in a WCMDocument. It has a set of static method that define all of the types.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentContentType : NSObject

/**
 @abstract The default of extension of the files of this type.
 @since 1.6
 */
@property (readonly) NSString* defaultExtension;

/**
 @abstract The default name of the files of this type.
 @since 1.6
 */
@property (readonly) NSString* defaultName;

/**
 @abstract The Internet media type of the files of this type.
 @since 1.6
 */
@property (readonly) NSString* mimeType;

/**
 @abstract Return a WCMDocumentContentType instance for resources of the PNG file format.
 @return A WCMDocumentContentType instance for resources of the PNG file format.
 @since 1.6
 */
+(WCMDocumentContentType*) PNG;

/**
 @abstract Return a WCMDocumentContentType instance for resources of the JPEG file format.
 @return A WCMDocumentContentType instance for resources of the JPEG file format.
 @since 1.6
 */
+(WCMDocumentContentType*) JPEG;

/**
 @abstract Return a WCMDocumentContentType instance for resources representing a serialized digital ink.
 Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 @return A WCMDocumentContentType instance for resources representing a serialized digital ink.
 @since 1.6
 */
+(WCMDocumentContentType*) STROKES;

/**
 @abstract Returns a WCMDocumentContentType instance for resources representing a serialized brush definitions for the digital ink.
 Please refer to [Encoding/Decoding ink content](/general-concepts/serialization/) article for more details.
 @return A WCMDocumentContentType instance for resources representing a serialized brush definitions for the digital ink.
 @since 1.6
 */
+(WCMDocumentContentType*) PAINTS;

/**
 @abstract Returns a corresponding WCMDocumentContentType instance, for the given MIME type.
 @param mimeType The MIME type string.
 @return A corresponding WCMDocumentContentType instance, for the given MIME type.
 @since 1.6
 */
+(WCMDocumentContentType*) getByMimeType:(NSString*)mimeType;

@end


/**
 A protocol implemented by elements that support affine transformations: WCMDocumentSectionGroup, WCMDocumentSectionPaths and WCMDocumentSectionImage.
 @since 1.6
 **/
WACOMINK_PUBLIC
@protocol WCMTransformableProtocol <NSObject>

/**
 @abstract Specifies the transform applied to the element. The transformation is relative to the (0,0) (the top-left) point of the parent element.
 @since 1.6
 */
@property CGAffineTransform transform;

@end


/**
 The WCMDocumentResource specifies a file resource of a WILL document (WCMDocument). The file is stored in a temporary folder. The file will be deleted from the file system, when the object is deallocated.
 */
WACOMINK_PUBLIC
@interface WCMDocumentResource : NSObject

/**
 @abstract The global path to the file resource.
 */
@property (readonly) NSString * path;

/**
 @abstract An instance of the WCMDocumentContentType describing the type of the resource.
 */
@property (readonly) WCMDocumentContentType* type;

/**
 @abstract Set the data and the type of the resource using with the content of a NSData object.
 @param data Instance of the NSData containing the data. The WCMDocumentResource will not keep the reference to the data, it will copy the content to a temporary folder.
 @param type Instance of the WCMDocumentContentType specifying the type of the data.
 */
-(void) setData:(NSData*)data withType:(WCMDocumentContentType*)type;

/**
 @abstract Set the data and the type of the resource using with the content file.
 @param path Global path to the file containing the data. The WCMDocumentResource class will only copy the content of the file to a temporary folder. The original file is not needed after this call.
 @param type Instance of the WCMDocumentContentType specifying the type of the data.
 */
-(void) setDataWithPath:(NSString*)path withType:(WCMDocumentContentType*)type;

/**
 @abstract Check if a file exists at the location of the path property.
 @return If a file exists at the location of the path property.
 */
-(BOOL) hasData;

/**
 @abstract Deletes the file (if it exists) at the location of the path property.
 @since 1.6
 */
-(void) removeData;

/**
 @abstract Creates and returns a new instance of the NSData class, with the content of the file found at the path property.
 @return A new instance of the NSData class, with the content of the file found at the path property.
 @since 1.6
 */
-(NSData*) loadData;

@end

@class WCMDocumentSectionContainer;

/**
 The WCMDocumentSectionElement class is an abstract class that all section elements inherit from.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionElement : NSObject

/**
 Gets a reference to the parent element of this element. For elements that are not added to a WCMDocumentSectionContainer this property should return nil.
 @since 1.6
 */
@property (readonly, weak) WCMDocumentSectionContainer* parent;

/**
 @abstract Removes the element from the subelements array of its parent. The parent property will be set to nil.
 @since 1.6
 */
-(void) removeFromParent;

@end


/**
 The WCMDocumentSectionContainer class an abstract class, that represent an element container. It maintains an array containing its subelements. Concrete classes that inherit from the WCMDocumentSectionContainer are the WCMDocumentSectionGroup and the WCMDocumentSection.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionContainer : WCMDocumentSectionElement

/**
 @abstract Appends an element to the end of this object's array of child elements.
 @param element The element to added to the subelements array.
 @since 1.6
 */
-(void) addElement:(WCMDocumentSectionElement*) element;

/**
 @abstract Inserts an element below another element in the hierarchy.
 @param element The element to insert. It’s removed from its parent if it’s not a sibling of siblingElement.
 @param siblingElement The sibling view that will be above the inserted view.
 @since 1.6
 */
-(void) insertElement:(WCMDocumentSectionElement *)element belowElement:(WCMDocumentSectionElement *)siblingElement;

/**
 @abstract Inserts an element above another element in the hierarchy.
 @param element The element to insert. It’s removed from its parent if it’s not a sibling of siblingElement.
 @param siblingElement The sibling view that will be below the inserted view.
 @since 1.6
 */
-(void) insertElement:(WCMDocumentSectionElement *)element aboveElement:(WCMDocumentSectionElement *)siblingElement;

/**
 @abstract Removes the element at the index specified from the subelements array. The parent property of the removed element will be set to nil.
 @param index The index in the subelements array, specifying the element to be removed.
 @since 1.6
 */
-(void) removeElementAtIndex:(NSUInteger)index;

/**
 @abstract The receiver’s immediate subelements.
 @since 1.6
 */
@property (readonly) NSArray* subelements;

/**
 @abstract Returns the element with index idx from the subelements array.
 @param idx The index of element from the subelements array.
 @return The element with index idx from the subelements array.
 @since 1.6
 */
-(id)objectAtIndexedSubscript:(NSUInteger)idx;

@end

/**
 The WCMDocumentSectionImage class represents an raster image element.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionImage : WCMDocumentSectionElement<WCMTransformableProtocol>

/**
 @abstract Instance of the WCMDocumentResource class storing the image data. The content type of the resource must be either [WCMDocumentContentType PNG] or [WCMDocumentContentType JPEG].
 @since 1.6
 */
@property (readonly) WCMDocumentResource * content;

/**
 @abstract Defines the size and position of image in the parent's coordinate system.
 @since 1.6
 */
@property CGRect rect;

@end

/**
 The WCMDocumentSectionRect class defines a graphics element - a rectangle filled with solid color.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionRect : WCMDocumentSectionElement

/**
 @abstract Defines the size and position of rectangle in the parent's coordinate system.
 @since 1.6
 */
@property CGRect bounds;

/**
 @abstract Defines the fill color of the rectangle.
 @since 1.6
 */
@property UIColor* fillColor;

@end


/**
 The WCMDocumentSectionPaths class represents a digital ink element.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionPaths : WCMDocumentSectionElement<WCMTransformableProtocol>

/**
 @abstract Instance of the WCMDocumentResource class storing the ink data. The ink data is usually created by an instance of the WCMInkEncoder class, and accessed with a WCMInkDecoder instance. The content type of the resource must be [WCMDocumentContentType STROKES].
 @since 1.6
 */
@property (readonly) WCMDocumentResource * content;

@end


/**
 The WCMDocumentSectionGroup class represents a group element. Group elements can be used as containers for other elements.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionGroup : WCMDocumentSectionContainer<WCMTransformableProtocol>

@end


/**
 Represents a view element. View elements are used for defining views inside a section.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSectionView : WCMDocumentSectionElement

/**
 @abstract Reference to an instance of WCMDocumentSectionGroup class, that is targeted by this view.
 @since 1.6
 */
@property WCMDocumentSectionGroup* viewTarget;

/**
 @abstract Boolean value that specifies whether the view is bookmarked.
 @since 1.6
 */
@property BOOL isBookmarked;

@end


/**
 The WCMDocumentSection class is the root of a tree hierarchy representing a scene in the WILL Document. It defines the size and the background of the scene. It contains digital ink along with other visual elements like images and graphics.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentSection : WCMDocumentSectionContainer

/**
 @abstract Defines the size of the scene represented by this instance.
 @since 1.6
 */
@property CGSize size;

/**
 @abstract Instance of the WCMDocumentResource class storing a image data used as a background of the scene. The image will be tiled so it fills the size of the scene.
 @since 1.6
 */
@property (readonly) WCMDocumentResource * background;

@end


/**
 The WCMDocumentProperties class groups various properties if a WILL document like its title, version and date of last modification.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocumentProperties : NSObject

/**
 @abstract String representing the version of the WILL document format. This property is read-only and is set automatically when the document is saved.
 @since 1.6
 */
@property (readonly) NSString * version;

/**
 @abstract String representing the title of the document. Set by the application developer, default value is nil.
 @since 1.6
 */
@property NSString * title;

/**
 @abstract Instance of the NSDate class, representing the date-time of the last modification of the document. When a new document is created, this property is automatically set to the current date.
 @since 1.6
 */
@property NSDate * lastModified;

/**
 @abstract String that identifies the application that created the document. Set by the application developer, default value is nil.
 @since 1.6
 */
@property NSString * application;

/**
 @abstract String that contains the creating application's version. Set by the application developer, default value is nil.
 @since 1.6
 */
@property NSString * appVersion;

/**
 @abstract String that identifies the document template. Optional field set by the application developer, default value is nil.
 @since 1.6
 */
@property NSString * appTemplate;

@end


/**
 The WCMDocument class represents a WILL document. WILL documents are used for storage of scenes that contain digital ink along with other visual elements like images and graphics.
 A single document can contain a number of sections, each section represent a scene. The scene is represented by a tree hierarchy, where the root is an instance of the WCMDocumentSection class, and each node is an instance of a class inherited from the WCMDocumentSectionElement class. Leaf nodes of type WCMDocumentSectionImage are used to represent an image, while instances of the WCMDocumentSectionPaths represent digital ink.
 
 Please refer to [Exchanging ink content](/general-concepts/file-format/) article for more details.
 @since 1.6
 */
WACOMINK_PUBLIC
@interface WCMDocument : NSObject

/**
 @abstract Loads a WILL document from the specified file path.
 @param path The path to the file from which the WILL document must be loaded.
 @return Whether or not the operation was successful.
 @since 1.6
 */
-(BOOL) loadDocumentAtPath:(NSString*)path;

/**
 @abstract Saves the WILL document to the specified file path. If a file already exists at the path, it will be overridden.
 @param path The file path at which the WILL document must be saved.
 @return Whether or not the operation was successful.
 @since 1.6
 */
-(BOOL) createDocumentAtPath:(NSString*)path;

/**
 @abstract An array the of WILL document sections. Each section represent a scene. Each scenes can contain digital ink along with other visual elements like images and graphics. The scene is represented by a tree hierarchy, where the root is an instance of the WCMDocumentSection. Must contain only instance of the WCMDocumentSection class. If other object is present in the array, an exception will be thrown by the [WCMDocument createDocumentAtPath:] method.
 @since 1.6
 */
@property (readonly) NSMutableArray* sections;

/**
 @abstract An array containing stroke brush definitions for the digital ink present in the document sections. Must contain only instance of the WCMParticlePaint class. If other object is present in the array, an exception will be thrown by the [WCMDocument createDocumentAtPath:] method.
 @since 1.6
 */
@property (readonly) NSMutableArray* paints;

/**
 @abstract An instance of the WCMDocumentProperties class, containing various document properties like its title and version.
 @since 1.6
 */
@property (readonly) WCMDocumentProperties* properties;

@end
