#ifndef ANTEXP_H
#define ANTEXP_H

#include "llvm/IR/PassManager.h"

namespace llvm {

class AntExpPass : public PassInfoMixin<AntExpPass> {
public:
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &AM);
};

} // namespace llvm

#endif // LLVM_TRANSFORMS_HELLONEW_HELLOWORLD_H