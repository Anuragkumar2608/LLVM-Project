; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefixes=RV32
; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck %s -check-prefixes=RV64

define i32 @optbranch_32(i32 %Arg) {
; RV32-LABEL: optbranch_32:
; RV32:       # %bb.0: # %bb
; RV32-NEXT:    li a1, -1
; RV32-NEXT:    beq a0, a1, .LBB0_2
; RV32-NEXT:  # %bb.1: # %bb3
; RV32-NEXT:    addi a0, a0, 1
; RV32-NEXT:    ret
; RV32-NEXT:  .LBB0_2: # %bb2
; RV32-NEXT:    li a0, -1
; RV32-NEXT:    ret
;
; RV64-LABEL: optbranch_32:
; RV64:       # %bb.0: # %bb
; RV64-NEXT:    sext.w a1, a0
; RV64-NEXT:    li a2, -1
; RV64-NEXT:    beq a1, a2, .LBB0_2
; RV64-NEXT:  # %bb.1: # %bb3
; RV64-NEXT:    addiw a0, a0, 1
; RV64-NEXT:    ret
; RV64-NEXT:  .LBB0_2: # %bb2
; RV64-NEXT:    li a0, -1
; RV64-NEXT:    ret
bb:
  %i1 = icmp eq i32 %Arg, -1
  br i1 %i1, label %bb2, label %bb3

bb2:
  ret i32 -1

bb3:
  %i4 = add nuw i32 %Arg, 1
  ret i32 %i4
}

define i64 @optbranch_64(i64 %Arg) {
; RV32-LABEL: optbranch_64:
; RV32:       # %bb.0: # %bb
; RV32-NEXT:    and a2, a0, a1
; RV32-NEXT:    li a3, -1
; RV32-NEXT:    beq a2, a3, .LBB1_2
; RV32-NEXT:  # %bb.1: # %bb3
; RV32-NEXT:    addi a2, a0, 1
; RV32-NEXT:    sltu a0, a2, a0
; RV32-NEXT:    add a1, a1, a0
; RV32-NEXT:    mv a0, a2
; RV32-NEXT:    ret
; RV32-NEXT:  .LBB1_2: # %bb2
; RV32-NEXT:    li a0, -1
; RV32-NEXT:    li a1, -1
; RV32-NEXT:    ret
;
; RV64-LABEL: optbranch_64:
; RV64:       # %bb.0: # %bb
; RV64-NEXT:    li a1, -1
; RV64-NEXT:    beq a0, a1, .LBB1_2
; RV64-NEXT:  # %bb.1: # %bb3
; RV64-NEXT:    addi a0, a0, 1
; RV64-NEXT:    ret
; RV64-NEXT:  .LBB1_2: # %bb2
; RV64-NEXT:    li a0, -1
; RV64-NEXT:    ret
bb:
  %i1 = icmp eq i64 %Arg, -1
  br i1 %i1, label %bb2, label %bb3

bb2:
  ret i64 -1

bb3:
  %i4 = add nuw i64 %Arg, 1
  ret i64 %i4
}

define i32 @test_lshr(i32 %v) {
; RV32-LABEL: test_lshr:
; RV32:       # %bb.0: # %entry
; RV32-NEXT:    beqz a0, .LBB2_3
; RV32-NEXT:  # %bb.1: # %for.body.preheader
; RV32-NEXT:    mv a1, a0
; RV32-NEXT:    li a0, 0
; RV32-NEXT:    li a2, 1
; RV32-NEXT:  .LBB2_2: # %for.body
; RV32-NEXT:    # =>This Inner Loop Header: Depth=1
; RV32-NEXT:    mv a3, a1
; RV32-NEXT:    andi a1, a1, 1
; RV32-NEXT:    add a0, a0, a1
; RV32-NEXT:    srli a1, a3, 1
; RV32-NEXT:    bltu a2, a3, .LBB2_2
; RV32-NEXT:  .LBB2_3: # %for.end
; RV32-NEXT:    ret
;
; RV64-LABEL: test_lshr:
; RV64:       # %bb.0: # %entry
; RV64-NEXT:    sext.w a1, a0
; RV64-NEXT:    beqz a1, .LBB2_3
; RV64-NEXT:  # %bb.1: # %for.body.preheader
; RV64-NEXT:    li a1, 0
; RV64-NEXT:    li a2, 1
; RV64-NEXT:  .LBB2_2: # %for.body
; RV64-NEXT:    # =>This Inner Loop Header: Depth=1
; RV64-NEXT:    sext.w a3, a0
; RV64-NEXT:    andi a4, a0, 1
; RV64-NEXT:    addw a1, a1, a4
; RV64-NEXT:    srliw a0, a0, 1
; RV64-NEXT:    bltu a2, a3, .LBB2_2
; RV64-NEXT:  .LBB2_3: # %for.end
; RV64-NEXT:    mv a0, a1
; RV64-NEXT:    ret
entry:
  %tobool.not4 = icmp eq i32 %v, 0
  br i1 %tobool.not4, label %for.end, label %for.body

for.body:                                         ; preds = %entry, %for.body
  %c.06 = phi i32 [ %add, %for.body ], [ 0, %entry ]
  %v.addr.05 = phi i32 [ %shr, %for.body ], [ %v, %entry ]
  %and = and i32 %v.addr.05, 1
  %add = add i32 %c.06, %and
  %shr = lshr i32 %v.addr.05, 1
  %tobool.not = icmp ult i32 %v.addr.05, 2
  br i1 %tobool.not, label %for.end, label %for.body

for.end:                                          ; preds = %for.body, %entry
  %c.0.lcssa = phi i32 [ 0, %entry ], [ %add, %for.body ]
  ret i32 %c.0.lcssa
}

define i32 @test_lshr2(ptr nocapture %x, ptr nocapture readonly %y, i32 %n) {
; RV32-LABEL: test_lshr2:
; RV32:       # %bb.0: # %entry
; RV32-NEXT:    li a3, 4
; RV32-NEXT:    bltu a2, a3, .LBB3_3
; RV32-NEXT:  # %bb.1: # %while.body.preheader
; RV32-NEXT:    srli a2, a2, 2
; RV32-NEXT:  .LBB3_2: # %while.body
; RV32-NEXT:    # =>This Inner Loop Header: Depth=1
; RV32-NEXT:    lw a3, 0(a1)
; RV32-NEXT:    addi a1, a1, 4
; RV32-NEXT:    slli a3, a3, 1
; RV32-NEXT:    addi a4, a0, 4
; RV32-NEXT:    addi a2, a2, -1
; RV32-NEXT:    sw a3, 0(a0)
; RV32-NEXT:    mv a0, a4
; RV32-NEXT:    bnez a2, .LBB3_2
; RV32-NEXT:  .LBB3_3: # %while.end
; RV32-NEXT:    li a0, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: test_lshr2:
; RV64:       # %bb.0: # %entry
; RV64-NEXT:    sext.w a3, a2
; RV64-NEXT:    li a4, 4
; RV64-NEXT:    bltu a3, a4, .LBB3_3
; RV64-NEXT:  # %bb.1: # %while.body.preheader
; RV64-NEXT:    srliw a2, a2, 2
; RV64-NEXT:  .LBB3_2: # %while.body
; RV64-NEXT:    # =>This Inner Loop Header: Depth=1
; RV64-NEXT:    lw a3, 0(a1)
; RV64-NEXT:    addi a1, a1, 4
; RV64-NEXT:    slli a3, a3, 1
; RV64-NEXT:    addi a4, a0, 4
; RV64-NEXT:    addiw a2, a2, -1
; RV64-NEXT:    sw a3, 0(a0)
; RV64-NEXT:    mv a0, a4
; RV64-NEXT:    bnez a2, .LBB3_2
; RV64-NEXT:  .LBB3_3: # %while.end
; RV64-NEXT:    li a0, 0
; RV64-NEXT:    ret
entry:
  %tobool.not4 = icmp ult i32 %n, 4
  br i1 %tobool.not4, label %while.end, label %while.body.preheader

while.body.preheader:                             ; preds = %entry
  %shr = lshr i32 %n, 2
  br label %while.body

while.body:                                       ; preds = %while.body.preheader, %while.body
  %c.07 = phi i32 [ %dec, %while.body ], [ %shr, %while.body.preheader ]
  %x.addr.06 = phi ptr [ %incdec.ptr1, %while.body ], [ %x, %while.body.preheader ]
  %y.addr.05 = phi ptr [ %incdec.ptr, %while.body ], [ %y, %while.body.preheader ]
  %incdec.ptr = getelementptr inbounds i32, ptr %y.addr.05, i32 1
  %0 = load i32, ptr %y.addr.05, align 4
  %mul = shl nsw i32 %0, 1
  %incdec.ptr1 = getelementptr inbounds i32, ptr %x.addr.06, i32 1
  store i32 %mul, ptr %x.addr.06, align 4
  %dec = add nsw i32 %c.07, -1
  %tobool.not = icmp eq i32 %dec, 0
  br i1 %tobool.not, label %while.end, label %while.body

while.end:                                        ; preds = %while.body, %entry
  ret i32 0
}