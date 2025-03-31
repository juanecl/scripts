# Group Words by Stems

This project processes a text file and groups words based on their linguistic roots (stems). It filters out stop words and generates a JSON file containing the frequency of each root along with its variations found in the text.

## Requirements

This script is written in **TypeScript** and requires **Node.js** to run. Additionally, it uses the `natural` library for natural language processing.

### Installation

Make sure you have Node.js installed and run the following command to install the necessary dependencies:

```sh
npm install
```

## Usage

The script takes two arguments:
1. **The name of the text file to be processed**
2. **The language of the file** (`spanish` or `english`)

Example execution:

```sh
node group_words.js input.txt spanish
```

This will generate a `results_stemmed.json` file with the processed information.

## How It Works

1. Reads the provided text file.
2. Splits the content into words.
3. Filters out stop words.
4. Reduces each word to its root (stemming) using `natural.PorterStemmer`.
5. Groups words based on their root and counts their occurrences.
6. Writes the results to `results_stemmed.json`, sorting words by frequency.

## Output File Format

The output file `results_stemmed.json` has the following format:

```json
{
  "stemmed_word": {
    "count": 10,
    "words": {
      "word": 5,
      "words": 5
    }
  }
}
```

Each key is a word root, and its value is an object containing:
- **count**: Total number of occurrences.
- **words**: A list of the original word forms and their respective counts.

## Notes

- Uses `natural.PorterStemmer` for English and `natural.PorterStemmerEs` for Spanish.
- Only words with more than one occurrence are included in the output file.
- If the file or language is not provided, the script will display an error message and terminate.

## Author
Juan Enrique Chomon Del Campo
This project was developed as an exercise in text processing using Node.js and TypeScript.

