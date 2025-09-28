# Test Templates

This directory contains templates for creating unit tests for the Perl Matrix Utils project.

## Files

### `test-template.t`
A comprehensive test template with:
- Complete test structure and boilerplate
- Examples of all common test patterns
- Best practices and guidelines
- Extensive comments and documentation
- Coverage for various scenarios (basic, edge cases, errors, etc.)

**Use this when:** Creating comprehensive test suites for new methods or features.

### `quick-test-template.t`
A minimal test template with:
- Basic test structure
- Essential patterns only
- Quick reference guide
- Minimal boilerplate

**Use this when:** Creating simple, focused tests or when you need a quick starting point.

## Usage

1. **Copy the appropriate template** to your test directory:
   ```bash
   cp author/test-template.t t/200-matrix/270-new-method.t
   # or
   cp author/quick-test-template.t t/100-vector/170-new-method.t
   ```

2. **Rename the file** to match your test purpose (following the existing naming convention)

3. **Replace placeholder content** with your actual tests:
   - Change `method_name` to your actual method name
   - Update test descriptions
   - Add/modify test cases as needed
   - Remove unused template sections

4. **Run your tests**:
   ```bash
   perl -Ilib t/directory/your-test-file.t
   # or
   prove -Ilib t/directory/your-test-file.t
   ```

## Test Organization

Follow the existing directory structure:
- `t/100-vector/` - Vector class tests
- `t/200-matrix/` - Matrix class tests
- `t/210-matrix-types/` - Specialized matrix type tests
- `t/000-machines/` - General machine/basic tests

## Naming Conventions

- Use descriptive filenames: `210-access.t`, `220-constructors.t`, etc.
- Use consistent numbering within directories
- Group related functionality together

## Key Testing Patterns

### Basic Test Structure
```perl
subtest 'method_name - what you're testing' => sub {
    # Setup
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    # Test
    my $result = $m->method_name();

    # Verify
    isa_ok( $result, 'Matrix', 'returns correct type' );
    is( $result->rows, 2, 'correct rows' );
    is( $result->at(0, 0), 1, 'element correct' );
};
```

### Error Testing
```perl
subtest 'method_name - error conditions' => sub {
    my $m = Matrix->new( shape => [2, 2], data => [1, 2, 3, 4] );

    throws_ok { $m->method_name('invalid') } qr/error pattern/, 'throws error for invalid input';
    throws_ok { $m->method_name() } 'Exception', 'throws specific exception type';
    lives_ok { $m->valid_method() } 'valid method should not throw';
};
```

### Loop Testing
```perl
for my $i (0..1) {
    for my $j (0..1) {
        is( $result->at($i, $j), $expected, "element at ($i,$j) correct" );
    }
}
```

## Common Assertions

- `isa_ok($obj, 'Class', 'description')` - Check object type
- `is($got, $expected, 'description')` - Exact equality
- `ok($condition, 'description')` - Boolean condition
- `like($string, qr/pattern/, 'description')` - Pattern matching
- `throws_ok { code } qr/pattern/, 'description'` - Test that code throws exception matching pattern
- `throws_ok { code } 'Exception::Class', 'description'` - Test that code throws specific exception type
- `lives_ok { code } 'description'` - Test that code doesn't throw exceptions
- `dies_ok { code } 'description'` - Test that code dies (alternative to throws_ok)

## Matrix/Vector Creation

```perl
# Matrix
my $m = Matrix->new( shape => [rows, cols], data => [array] );
my $eye = Matrix->eye(n);  # Identity matrix
my $zeros = Matrix->initialize([rows, cols], 0);

# Vector
my $v = Vector->new( size => n, data => [array] );
```

## Running Tests

Always include `-Ilib` to find the modules:
```bash
perl -Ilib t/directory/test-file.t
prove -Ilib t/directory/test-file.t
```

## Best Practices

1. **Test coverage**: Include basic functionality, edge cases, and error conditions
2. **Descriptive names**: Use clear, descriptive test and subtest names
3. **Consistent patterns**: Follow existing test patterns in the codebase
4. **Error testing**: Use Test::Exception functions (throws_ok, lives_ok, dies_ok) for cleaner exception testing
5. **Comments**: Add comments for complex logic or non-obvious expectations
6. **Cleanup**: Remove unused template sections and placeholder content
7. **Exception patterns**: Use regex patterns in throws_ok to test specific error messages

## Examples

See existing test files for real examples:
- `t/200-matrix/210-access.t` - Access method tests
- `t/200-matrix/220-constructors.t` - Constructor tests
- `t/200-matrix/260-concat-stack.t` - Operation tests
- `t/100-vector/110-access.t` - Vector access tests
