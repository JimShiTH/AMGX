/* Copyright (c) 2013-2017, NVIDIA CORPORATION. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of NVIDIA CORPORATION nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

namespace amgx
{

template <class T_Config> class Operator;

}

#include <operators/deflated_multiply_operator.h>
#include <blas.h>

namespace amgx
{

template <typename TConfig>
void DeflatedMultiplyOperator<TConfig>::apply(const Vector<TConfig> &v, Vector<TConfig> &res, ViewType view)
{
    Operator<TConfig> &A = *m_A;
    int offset, size;
    A.getOffsetAndSizeForView(view, &offset, &size);
    copy(v, *m_work, offset, size);
    ValueTypeVec xtv = dot(A, *m_x, *m_work);
    axpy(*m_x, *m_work, types::util<ValueTypeVec>::invert(xtv), offset, size);
    A.apply(*m_work, res, OWNED);
    axpy(*m_work, res, types::util<ValueTypeVec>::invert(m_mu), offset, size);
    ValueTypeVec xtres = dot(A, *m_x, res);
    axpy(*m_x, res, types::util<ValueTypeVec>::invert(xtres), offset, size);
}

#define AMGX_CASE_LINE(CASE) template class DeflatedMultiplyOperator<TemplateMode<CASE>::Type>;
AMGX_FORALL_BUILDS(AMGX_CASE_LINE)
AMGX_FORCOMPLEX_BUILDS(AMGX_CASE_LINE)
#undef AMGX_CASE_LINE

}
