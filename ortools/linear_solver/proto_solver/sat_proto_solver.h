// Copyright 2010-2025 Google LLC
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef OR_TOOLS_LINEAR_SOLVER_PROTO_SOLVER_SAT_PROTO_SOLVER_H_
#define OR_TOOLS_LINEAR_SOLVER_PROTO_SOLVER_SAT_PROTO_SOLVER_H_

#include <atomic>
#include <functional>
#include <string>

#include "ortools/linear_solver/linear_solver.pb.h"
#include "ortools/util/lazy_mutable_copy.h"
#include "ortools/util/logging.h"

namespace operations_research {

// Solve the input MIP model with the SAT solver.
//
// If possible, std::move the request into this function call to avoid a copy.
//
// If you need to change the solver parameters, please use the
// EncodeParametersAsString() function to set the request's
// solver_specific_parameters field.
//
// The optional interrupt_solve can be used to interrupt the solve early. It
// must only be set to true, never reset to false. It is also used internally by
// the solver that will set it to true for its own internal logic. As a
// consequence the caller should ignore the stored value and should not use the
// same atomic for different concurrent calls.
//
// The optional logging_callback will be called when the SAT parameter
// log_search_progress is set to true. Passing a callback will disable the
// default logging to INFO. Note though that by default the SAT parameter
// log_to_stdout is true so even with a callback, the logs will appear on stdout
// too unless log_to_stdout is set to false. The enable_internal_solver_output
// in the request will act as the SAT parameter log_search_progress.
//
// The optional solution_callback will be called on each intermediate solution
// found by the solver. The solver may call solution_callback from multiple
// threads, but it will ensure that at most one thread executes
// solution_callback at a time.
MPSolutionResponse SatSolveProto(
    LazyMutableCopy<MPModelRequest> request,
    std::atomic<bool>* interrupt_solve = nullptr,
    std::function<void(const std::string&)> logging_callback = nullptr,
    std::function<void(const MPSolution&)> solution_callback = nullptr);

// Returns a string that describes the version of the CP-SAT solver.
std::string SatSolverVersion();

}  // namespace operations_research

#endif  // OR_TOOLS_LINEAR_SOLVER_PROTO_SOLVER_SAT_PROTO_SOLVER_H_
