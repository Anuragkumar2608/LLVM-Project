; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -S -mtriple=aarch64 -passes=slp-vectorizer | FileCheck %s

%struct.buf = type { [8 x i8] }

define i8 @reduce_xor(ptr %a, ptr %b) {
; CHECK-LABEL: @reduce_xor(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP1:%.*]] = load <8 x i8>, ptr [[A:%.*]], align 1
; CHECK-NEXT:    [[TMP3:%.*]] = load <8 x i8>, ptr [[B:%.*]], align 1
; CHECK-NEXT:    [[TMP4:%.*]] = and <8 x i8> [[TMP3]], [[TMP1]]
; CHECK-NEXT:    [[TMP5:%.*]] = call i8 @llvm.vector.reduce.xor.v8i8(<8 x i8> [[TMP4]])
; CHECK-NEXT:    [[OP_RDX:%.*]] = xor i8 [[TMP5]], 1
; CHECK-NEXT:    ret i8 [[OP_RDX]]
;
entry:
  %0 = load i8, ptr %a, align 1
  %1 = load i8, ptr %b, align 1
  %and12 = and i8 %1, %0
  %arrayidx.1 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 1
  %2 = load i8, ptr %arrayidx.1, align 1
  %arrayidx3.1 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 1
  %3 = load i8, ptr %arrayidx3.1, align 1
  %and12.1 = and i8 %3, %2
  %4 = xor i8 %and12, %and12.1
  %arrayidx.2 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 2
  %5 = load i8, ptr %arrayidx.2, align 1
  %arrayidx3.2 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 2
  %6 = load i8, ptr %arrayidx3.2, align 1
  %and12.2 = and i8 %6, %5
  %7 = xor i8 %4, %and12.2
  %arrayidx.3 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 3
  %8 = load i8, ptr %arrayidx.3, align 1
  %arrayidx3.3 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 3
  %9 = load i8, ptr %arrayidx3.3, align 1
  %and12.3 = and i8 %9, %8
  %10 = xor i8 %7, %and12.3
  %arrayidx.4 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 4
  %11 = load i8, ptr %arrayidx.4, align 1
  %arrayidx3.4 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 4
  %12 = load i8, ptr %arrayidx3.4, align 1
  %and12.4 = and i8 %12, %11
  %13 = xor i8 %10, %and12.4
  %arrayidx.5 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 5
  %14 = load i8, ptr %arrayidx.5, align 1
  %arrayidx3.5 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 5
  %15 = load i8, ptr %arrayidx3.5, align 1
  %and12.5 = and i8 %15, %14
  %16 = xor i8 %13, %and12.5
  %arrayidx.6 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 6
  %17 = load i8, ptr %arrayidx.6, align 1
  %arrayidx3.6 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 6
  %18 = load i8, ptr %arrayidx3.6, align 1
  %and12.6 = and i8 %18, %17
  %19 = xor i8 %16, %and12.6
  %arrayidx.7 = getelementptr inbounds %struct.buf, ptr %a, i64 0, i32 0, i64 7
  %20 = load i8, ptr %arrayidx.7, align 1
  %arrayidx3.7 = getelementptr inbounds %struct.buf, ptr %b, i64 0, i32 0, i64 7
  %21 = load i8, ptr %arrayidx3.7, align 1
  %and12.7 = and i8 %21, %20
  %22 = xor i8 %19, %and12.7
  %xor13.7 = xor i8 %22, 1
  ret i8 %xor13.7
}