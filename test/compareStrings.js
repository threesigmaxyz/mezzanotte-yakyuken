function removeSpacesAndCompareStrings(str1, str2) {
    // Remove spaces from the strings
    const stringWithoutSpaces1 = str1.replace(/\s/g, '').replace(/\n/g, '');
    const stringWithoutSpaces2 = str2.replace(/\s/g, '').replace(/\n/g, '');

    // Compare the modified strings
    const areEqual = stringWithoutSpaces1 === stringWithoutSpaces2;
  
    return areEqual;
  }
  const fs = require('fs');

  // Get command-line arguments
  const inputFile1 = process.argv[2];
  const inputFile2 = process.argv[3];

  // Check if both input file paths are provided
  if (!inputFile1 || !inputFile2) {
    console.log('Please provide two input file paths.');
    process.exit(1);
  }

  // Read the contents of input files
  fs.readFile(inputFile1, 'utf8', (err1, data1) => {
    if (err1) {
      console.error(`Error reading ${inputFile1}: ${err1.message}`);
      process.exit(1);
    }
    fs.readFile(inputFile2, 'utf8', (err2, data2) => {
      if (err2) {
        console.error(`Error reading ${inputFile2}: ${err2.message}`);
        process.exit(1);
      }

      // Remove spaces and compare the contents of the two files
      const areStringsEqual = removeSpacesAndCompareStrings(data1.trim(), data2.trim());

      console.log(`${areStringsEqual}`);
    });
  });

  