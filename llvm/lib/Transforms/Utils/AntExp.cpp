#include "llvm/Transforms/Utils/AntExp.h"
#include "llvm/ADT/SetOperations.h"
#include "llvm/ADT/Statistic.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/InstIterator.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Instruction.h"
#include <list>
#include <map>
#include <queue>
#include "llvm/ADT/BitVector.h"
#include "llvm/Frontend/OpenMP/OMPConstants.h"
#include "llvm/IR/InstrTypes.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Value.h"
#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/ValueSymbolTable.h"
#include "llvm/Support/raw_ostream.h"
#include <unordered_set>
#include "llvm/IR/Function.h"
#include "llvm/Pass.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/CFG.h"
#include "llvm/IR/Constants.h"
#include "llvm/ADT/BitVector.h"
#include "llvm/ADT/DenseMap.h"
#include <vector>
#include <set>


using namespace llvm;
using namespace std;

set<Instruction *> universalSet;
map<BasicBlock *, set<Instruction *>> useMap;
map<BasicBlock *, set<Instruction *>> defineMap;
map<BasicBlock *, set<Instruction *>> inMap;
map<BasicBlock *, set<Instruction *>> outMap;

set<Instruction *> defined_block;
set<Instruction *> used_block;

bool isValidExpression(Instruction *I){
  if( isa<CallInst>(I) || I->isBinaryOp() || I->isUnaryOp() || 
   isa<SelectInst>(I) || isa<CmpInst>(I) ||
   I->getOpcode() == 53 || I->getOpcode() == 54 ||
   I->getOpcode() == 56 || I->getOpcode() == 57)return true;
  return false;
}

bool compareInsts(Instruction* bin1, Instruction* bin2){
  if(bin1->isIdenticalTo(bin2)) return true;
  return false;
}

void computeDefandUse(BasicBlock* bb){
  for (Instruction &I : *bb) {
    bool flag = true;
    if (isValidExpression(&I)) {
      for (Use &U : I.operands()) {
        Value *v = U.get();
        Instruction* inst = dyn_cast<Instruction>(v);
        if (inst && inst->getParent() == (bb)) {
          flag = false;
        }
      }
      if (flag) {
        used_block.insert(&I);
      }
    }
    for (User *U : I.users()) {
      Instruction* inst = dyn_cast<Instruction>(U);
      if (inst && isValidExpression(inst)){
        defined_block.insert(inst);
      }
    }
  }
}

bool computeInAndOut(Function &F){
  bool change = false;
  for (BasicBlock &BB : F) {
    bool flag = true;
    set<Instruction *> outSet;
    set<Instruction *> InSet;
    for (BasicBlock *succ : successors(&BB)) {
      if (flag) {
        for(Instruction *inst:inMap[succ]){
          outSet.insert(inst);
        }
        flag = false;
      } else {
        set<Instruction *> intersection;
        for (auto &inst2 : outSet) {
          for (auto &inst1 : inMap[succ]) {
            if (compareInsts(inst1, inst2)) {
              intersection.insert(inst1);
            }
          }
        }
        outSet.clear();
        outSet.insert(intersection.begin(), intersection.end());
      }
    }
    set_union(InSet, set_difference(outSet, defineMap[&BB]));
    set_union(InSet, useMap[&BB]);
    if (inMap[&BB] != InSet || outMap[&BB] != outSet)
      change = true;
    outMap[&BB] = outSet;
    inMap[&BB] = InSet;
  }
  return !change;
}

bool hoistAntExpr(vector<BasicBlock*>&v){
  bool change = false;
  set<Instruction *> hoistInsts;
  for (auto *bb : v) {
    for (Instruction *inst : outMap[bb]) {
      inst->moveBefore(bb->getTerminator());
      for (auto *succ : successors(bb)) {
        for (Instruction &i : *succ) {
          if (i.isIdenticalToWhenDefined(inst)) {
            Value *op = dyn_cast<Value>(inst);
            i.replaceAllUsesWith(op);
            hoistInsts.insert(&i);
          }
        }
      }
    }
  }
  for (Instruction *I : hoistInsts) {
    I->eraseFromParent();
    change = true;
  }
  return change;
}

void BFS(Function &F,vector<BasicBlock*>&v){
  queue<BasicBlock*>q;
  q.push(&(F.getEntryBlock()));
  unordered_set<BasicBlock *>incl;
  incl.insert(&(F.getEntryBlock()));
  while(!q.empty()){
    BasicBlock *b=q.front();
    v.push_back(b);
    q.pop();
    for(auto *s:successors(b)){
      if(incl.find(s)==incl.end()){
        incl.insert(s);
        q.push(s);
      }
    }
  }
}

PreservedAnalyses AntExpPass::run(Function &F,
                                      FunctionAnalysisManager &AM) {
  bool flag = true;
      while (flag) {
        flag = false;
        for(auto &bb:F){
          for(auto &&ii: bb){
            bool alreadyPresent = false; 
            for(Instruction* op : universalSet){
              if(compareInsts(&ii, op)){
                alreadyPresent = true;
              }
            }
            if(!alreadyPresent){
              universalSet.insert(&ii);
            }
          }
        }
        for (auto &BB : F) {
          computeDefandUse(&BB);
          useMap[&BB] = used_block;
          defineMap[&BB] = defined_block;
          inMap[&BB] = universalSet;
          used_block.clear();
          defined_block.clear();
        }
        bool converge = false;
        while (!converge) {
          converge = true;
          converge = computeInAndOut(F);
        }
        vector<BasicBlock *>v;
        BFS(F,v);
        reverse(v.begin(),v.end());
        flag = hoistAntExpr(v);
      }
  //   for(auto &B:F){
  //   errs() << B;
  // }


  PreservedAnalyses PA;
  PA.preserveSet<CFGAnalyses>();
  return PA; 
}
