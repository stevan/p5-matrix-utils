# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A Perl 5.40+ tensor/matrix/vector library using experimental Perl class syntax. Implements n-dimensional arrays (tensors) with specialized Matrix, Vector, and Scalar subclasses for numerical computations.

## Requirements

- Perl 5.40 or higher (uses `use v5.40` and `experimental qw[ class ]`)
- Test::More, Test::Exception for testing

## Running Tests

```bash
# Run all tests
prove -l t/

# Run a specific test file
prove -l t/100-vector/110-access.t

# Run tests in a specific directory
prove -l t/100-vector/

# Run with verbose output
prove -lv t/
```

Note: The `-l` flag adds `lib/` to the include path so modules can be found.

## Architecture

### Core Class Hierarchy

```
Tensor (lib/Tensor.pm)
├── Vector (lib/Vector.pm)
├── Matrix (lib/Matrix.pm)
└── Scalar (lib/Scalar.pm)
```

**Tensor** is the base class providing:
- N-dimensional array storage with shape/strides/data
- Index calculations via strides (row-major order)
- Generic operations: `unary_op`, `binary_op`, `reduce_data_array`, `map_data_array`, `zip_data_arrays`
- Math operations: add, sub, mul, div, mod, pow, neg, abs
- Comparison operations: eq, ne, lt, le, gt, ge, cmp
- Logical operations: not, and, or
- Numerical operations: trunc, fract, round_down, round_up, clamp, min, max
- Operator overloading (+, -, *, /, %, **, ==, !=, <, <=, >, >=, !, <=>)
- Contains `Tensor::Ops` package with primitive operations

**Vector** (rank 1 tensor):
- Extends Tensor with 1D-specific methods
- Vector concatenation, matrix multiplication, dot product
- Reductions: min_value, max_value
- index_of for finding values

**Matrix** (rank 2 tensor):
- Extends Tensor with 2D-specific methods
- Accessors: rows, cols, height, width
- Row/column operations: row_at, col_at, row_vector_at, col_vector_at, row_indices, col_indices
- Static constructors: concat, stack, square, eye, diagonal
- Matrix multiplication (matrix × matrix, matrix × vector)
- Shifting operations: shift_horz (horizontal shift)
- Special binary_op handling when operating with vectors (broadcasts vector across matrix rows)

**Scalar** (rank 0 tensor):
- Wraps single values for uniform interface
- Overloads numeric conversion (0+) and boolean context
- Can be used for indexing tensors (auto-unwraps via `->at(0)`)

### Key Design Patterns

**Strides-based indexing**: Multi-dimensional coordinates converted to flat array indices using stride calculations. Strides are computed once during construction and cached.

**Data array operations**: All operations route through `map_data_array`, `zip_data_arrays`, or `reduce_data_array` which operate on the flat internal data array. This allows operations to work uniformly across all tensor ranks.

**Uniform interface**: Scalars, vectors, and tensors work interchangeably in operations. Binary operations auto-unwrap Scalars and broadcast appropriately.

**Lazy static constructors**: `construct` method takes a shape and generator function, allowing efficient construction of matrices/vectors from formulas rather than pre-computed data.

### Test Organization

```
t/
├── 000-tensor/      # Tensor base class tests (access, constructors, math, comparisons, etc.)
├── 010-core/        # Core Tensor functionality (ops, reduce, scalars)
├── 100-vector/      # Vector-specific tests (access, math, reductions, concat)
└── 200-matrix/      # Matrix-specific tests (access, constructors, ops, math, concat/stack)
```

Tests use numbered prefixes (e.g., 010-, 110-, 120-) to control execution order within directories.

## Development Notes

- All modules use Perl 5.40+ class syntax (not Moose/Moo)
- The `__CLASS__` token is used in Tensor methods to ensure subclasses return correct type
- Operator overloading defined in Tensor base class applies to all subclasses
- Matrix binary operations have special case for Vector operands (broadcasts vector across rows)
- Index bounds checking uses `Carp::confess` for stack traces
- Future enhancement idea: lazy evaluation for chained operations (see NOTES.md)

## Neural Network / Machine Learning Features

The library includes features specifically for building neural networks:

**Random Initialization**:
```perl
my $W = Matrix->random([784, 128], -0.1, 0.1);  # Uniform distribution
my $W = Matrix->randn([784, 128], 0, 0.01);     # Normal/Gaussian distribution
```

**Activation Functions**:
```perl
my $activated = $tensor->relu();      # ReLU: max(0, x)
my $activated = $tensor->sigmoid();   # Sigmoid: 1/(1+exp(-x))
my $activated = $tensor->tanh();      # Hyperbolic tangent
my $probs = $tensor->softmax();       # Softmax for classification
```

**Matrix Operations**:
```perl
my $transposed = $matrix->transpose();           # Essential for backprop
my $result = $matrix->matrix_multiply($vector);  # Linear layer
```

**Mathematical Functions**:
```perl
my $result = $tensor->exp();    # Element-wise exponential
my $result = $tensor->log();    # Element-wise natural log
my $result = $tensor->sqrt();   # Element-wise square root
```

**Reductions**:
```perl
my $total = $tensor->sum();     # Sum all elements
my $avg = $tensor->mean();      # Average of all elements
```

See `examples/mnist_network.pl` for a complete neural network implementation.

## Common Patterns

**Creating tensors/matrices/vectors**:
```perl
# Explicit constructor with shape and data
my $m = Matrix->new(shape => [3, 3], data => [1..9]);

# Initialize with shape and initial value/array
my $v = Vector->initialize(5, [1, 2, 3, 4, 5]);
my $m = Matrix->initialize([2, 3], 0);  # 2×3 matrix of zeros

# Static constructors
my $eye = Matrix->eye(3);               # 3×3 identity matrix
my $zeros = Matrix->zeros([2, 3]);      # 2×3 zero matrix
my $ones = Vector->ones(5);             # 5-element vector of 1s
my $seq = Vector->sequence(5, 1);       # [1, 2, 3, 4, 5]

# Random initialization (for neural networks)
my $rand = Matrix->random([10, 10], -1, 1);     # Uniform [-1, 1]
my $randn = Matrix->randn([10, 10], 0, 0.1);   # Normal μ=0, σ=0.1

# Construct from generator function
my $m = Matrix->construct([3, 3], sub ($x, $y) { $x + $y });
```

**Accessing data**:
```perl
my $val = $tensor->at(0, 1);           # Get element at coordinates
my @row = $matrix->row_at(0);          # Get row as list
my $vec = $matrix->row_vector_at(0);   # Get row as Vector object
```

**Operations**:
```perl
my $result = $v1->add($v2);            # Element-wise addition
my $result = $v1 + $v2;                # Via overloaded operator
my $result = $m->matrix_multiply($v);  # Matrix-vector multiplication
my $result = $m->transpose();          # Matrix transpose
```
