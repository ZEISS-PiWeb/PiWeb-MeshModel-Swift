import XCTest
@testable import PiWebMeshModel

class MeshModelTests: XCTestCase {
    
    let modelsToTest = [ "Cube", "MetalPart", "Panel" ]
    
    func test_meshModelLoading_isWorkingProperly() {
        for modelName in modelsToTest {
            let filename = MeshModelTests.read(model: modelName)!
            let model = MeshModel.init(filename: filename)
            
            XCTAssertNotNil(model)
        }
    }
    
    func test_meshModelLoadingPerformance_isAcceptible() {
        let filename = MeshModelTests.read(model: "MetalPart")!
        measure {
            let _ = MeshModel.init(filename: filename)
        }
    }
    
    static func read(model: String) -> String? {
        let bundle = Bundle(for: TestClass.self)
        if let path = bundle.path(forResource: model, ofType: "meshModel") {
            return path
        }
        XCTFail("Unable to read MeshModel file '\(model)'")
        
        return nil
    }
    @objc class TestClass: NSObject { }
    
}
