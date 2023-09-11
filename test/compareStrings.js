function removeSpacesAndCompareStrings(str1, str2) {
    // Remove spaces from the strings
    const stringWithoutSpaces1 = str1.replace(/\s/g, '').replace(/\n/g, '');
    const stringWithoutSpaces2 = str2.replace(/\s/g, '').replace(/\n/g, '');
  
    // Compare the modified strings
    const areEqual = stringWithoutSpaces1 === stringWithoutSpaces2;
  
    return areEqual;
  }
  
  // Get command-line arguments
  const inputString1 = process.argv[2];
  const inputString2 = process.argv[3];
  
  // Check if both input strings are provided
  if (!inputString1 || !inputString2) {
    console.log('Please provide two input strings.');
    process.exit(1);
  }
  
  const areStringsEqual = removeSpacesAndCompareStrings(inputString1, inputString2);
  
  console.log(`${areStringsEqual}`);
  