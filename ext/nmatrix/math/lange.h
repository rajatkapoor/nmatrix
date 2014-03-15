/////////////////////////////////////////////////////////////////////
// = NMatrix
//
// A linear algebra library for scientific computation in Ruby.
// NMatrix is part of SciRuby.
//
// NMatrix was originally inspired by and derived from NArray, by
// Masahiro Tanaka: http://narray.rubyforge.org
//
// == Copyright Information
//
// SciRuby is Copyright (c) 2010 - 2014, Ruby Science Foundation
// NMatrix is Copyright (c) 2012 - 2014, John Woods and the Ruby Science Foundation
//
// Please see LICENSE.txt for additional copyright notices.
//
// == Contributing
//
// By contributing source code to SciRuby, you agree to be bound by
// our Contributor Agreement:
//
// * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
//
// == lange.h
//
// Header file for interface with LAPACK's xLANGE functions.
//

#ifndef LANGE_H
# define LANGE_H

extern "C" {
  float slange_(char* norm, int* m, int* n, float* a, int* lda, float* work);
  double dlange_(char* norm, int* m, int* n, double* a, int* lda, double* work);
  nm::Complex64 clange_(char* norm, int* m, int* n, nm::Complex64* a, int* lda, nm::Complex64* work);
  nm::Complex128 zlange_(char* norm, int* m, int* n, nm::Complex128* a, int* lda, nm::Complex128* work);
}

namespace nm { namespace math {

template <typename DType>
inline DType lange(char norm, int m, int n, DType* a, int lda, DType* work) {
  rb_raise(rb_eNotImpError, "not yet implemented for non-BLAS dtypes");
  return -1;
}

template <>
inline float lange(char norm, int m, int n, float* a, int lda, float* work) {
  return slange_(&norm, &m, &n, a, &lda, work);
}

template <>
inline double lange(char norm, int m, int n, double* a, int lda, double* work) {
  return dlange_(&norm, &m, &n, a, &lda, work);
  
}

template <>
inline Complex64 lange(char norm, int m, int n, Complex64* a, int lda, Complex64* work) {
  return clange_(&norm, &m, &n, a, &lda, work);
  
}

template <>
inline Complex128 lange(char norm, int m, int n, Complex128* a, int lda, Complex128* work) {
  return zlange_(&norm, &m, &n, a, &lda, work);
  
}

template <typename DType>
inline int lapack_lange(char norm, int m, int n, void* a, int lda, void* work) {
  return lange<DType>(norm, m, n, reinterpret_cast<DType*>(a), lda, reinterpret_cast<DType*>(work));
}

}} // end nm::math

#endif // LANGE_H
