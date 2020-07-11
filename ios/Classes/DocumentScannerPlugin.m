#import "DocumentScannerPlugin.h"
#if __has_include(<document_scanner/document_scanner-Swift.h>)
#import <document_scanner/document_scanner-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "document_scanner-Swift.h"
#endif

@implementation DocumentScannerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDocumentScannerPlugin registerWithRegistrar:registrar];
}
@end
