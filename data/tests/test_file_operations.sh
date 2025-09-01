#!/bin/bash
# Tests basic file operations
echo "Running file operations tests..."
touch ./data/tests/test_file.txt
if [ -f ./data/tests/test_file.txt ]; then
    echo "File creation test: PASSED"
else
    echo "File creation test: FAILED"
fi
echo "Moving file..."
mv ./data/tests/test_file.txt ./data/tests/test_file_moved.txt
if [ -f ./data/tests/test_file_moved.txt ]; then
    echo "File move test: PASSED"
else
    echo "File move test: FAILED"
fi
echo "Listing files..."
ls -la ./data/tests/ > ./data/tests/test_results.txt
echo "Test results written to ./data/tests/test_results.txt"
