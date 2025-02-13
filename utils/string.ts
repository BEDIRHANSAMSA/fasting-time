/**
 * Converts a string to lowercase and properly handles Turkish characters
 * @param str The string to convert to lowercase
 * @returns The lowercase version of the string with proper Turkish character handling
 */
export function toLowerCaseUTF8(str: string): string {
  return str.replace(/İ/g, 'i').replace(/I/g, 'ı').toLowerCase();
}

/**
 * Converts a string to title case while properly handling Turkish characters
 * @param str The string to convert to title case
 * @returns The title case version of the string with proper Turkish character handling
 */
export function toTitleCaseUTF8(str: string): string {
  return str
    .split(' ')
    .map((word) => {
      if (word.length === 0) return word;

      // Convert the word to lowercase first
      const lowerWord = toLowerCaseUTF8(word);

      // Convert each character with proper Turkish case handling
      return lowerWord
        .split('')
        .map((char, index) => {
          if (index === 0) {
            // First character should be uppercase
            if (char === 'i') return 'İ';
            if (char === 'ı') return 'I';
            return char.toUpperCase();
          } else {
            // Handle I/i cases in the rest of the word
            if (char === 'i') return 'i';
            if (char === 'ı') return 'ı';
            return char;
          }
        })
        .join('');
    })
    .join(' ');
}

/**
 * Converts a country code to an emoji flag
 * @param countryCode The two-letter country code
 * @returns The emoji flag for the country
 */
export function getFlagEmoji(countryCode: string) {
  const codePoints = countryCode
    .toUpperCase()
    .split('')
    .map((char) => 127397 + char.charCodeAt(0));
  return String.fromCodePoint(...codePoints);
}
