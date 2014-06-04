
import Foundation

@objc class LRFileTarget : LRTarget {

    let sourceFile: LRProjectFile

    init(action: Action, sourceFile: LRProjectFile) {
        self.sourceFile = sourceFile
        super.init(action: action)
    }

    override func invoke(#build: LRBuild, completionBlock: dispatch_block_t) {
        build.markAsConsumedByCompiler(sourceFile)
        if !sourceFile.exists {
            action.handleDeletionOfFile(sourceFile, inProject: self.project)
            completionBlock()
        } else {
            let result = newResult()
            result.defaultMessageFile = sourceFile

            action.compileFile(sourceFile, inProject: project, result: result) {
                if result.invocationError {
                    NSLog("Error compiling \(self.sourceFile.relativePath): \(result.invocationError.domain) - \(result.invocationError.code) - \(result.invocationError.localizedDescription)")
                }
                build.addOperationResult(result, forTarget: self, key: "\(self.project.path).\(self.sourceFile.relativePath)")
                completionBlock()
            }
        }
    }

}