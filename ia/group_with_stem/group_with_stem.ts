import { readFile, writeFile } from 'fs/promises';
import * as natural from 'natural';

/**
 * List of stop words in Spanish and English
 */
const stopWords: { [key: string]: string[] } = {
  spanish: [
    "a", "al", "algo", "algunas", "algunos", "ante", "antes", "como", "con", "contra", "cual", "cuando", "de", "del", "desde", "donde", "durante", "e", "el", "ella", "ellas", "ellos", "en", "entre", "era", "erais", "eran", "eras", "eres", "es", "esa", "esas", "ese", "eso", "esos", "esta", "estaba", "estabais", "estaban", "estabas", "estad", "estada", "estadas", "estado", "estados", "estamos", "estando", "estar", "estaremos", "estará", "estarán", "estarás", "estaré", "estaréis", "estaría", "estaríais", "estaríamos", "estarían", "estarías", "estas", "este", "estemos", "esto", "estos", "estoy", "estuve", "estuviera", "estuvierais", "estuvieran", "estuvieras", "estuvieron", "estuviese", "estuvieseis", "estuviesen", "estuvieses", "estuvimos", "estuviste", "estuvisteis", "estuviéramos", "estuviésemos", "estuvo", "está", "estábamos", "estáis", "están", "estás", "esté", "estéis", "estén", "estés", "fue", "fuera", "fuerais", "fueran", "fueras", "fueron", "fuese", "fueseis", "fuesen", "fueses", "fui", "fuimos", "fuiste", "fuisteis", "ha", "habida", "habidas", "habido", "habidos", "habiendo", "habremos", "habrá", "habrán", "habrás", "habré", "habréis", "habría", "habríais", "habríamos", "habrían", "habrías", "han", "has", "hasta", "hay", "haya", "hayamos", "hayan", "hayas", "he", "hemos", "hube", "hubiera", "hubierais", "hubieran", "hubieras", "hubieron", "hubiese", "hubieseis", "hubiesen", "hubieses", "hubimos", "hubiste", "hubisteis", "hubiéramos", "hubiésemos", "hubo", "la", "las", "le", "les", "lo", "los", "me", "mi", "mis", "mucho", "muchos", "muy", "más", "mí", "mía", "mías", "mío", "míos", "nada", "ni", "no", "nos", "nosotras", "nosotros", "nuestra", "nuestras", "nuestro", "nuestros", "o", "os", "otra", "otras", "otro", "otros", "para", "pero", "poco", "por", "porque", "que", "quien", "quienes", "qué", "se", "sea", "seamos", "sean", "seas", "seremos", "será", "serán", "serás", "seré", "seréis", "sería", "seríais", "seríamos", "serían", "serías", "seáis", "sido", "siendo", "sin", "sobre", "sois", "solamente", "solo", "somos", "son", "soy", "su", "sus", "suya", "suyas", "suyo", "suyos", "sí", "también", "tanto", "te", "tenida", "tenidas", "tenido", "tenidos", "teniendo", "tenéis", "tenemos", "tendremos", "tendrá", "tendrán", "tendrás", "tendré", "tendréis", "tendría", "tendríais", "tendríamos", "tendrían", "tendrías", "tened", "tenemos", "tengo", "tenía", "teníais", "teníamos", "tenían", "tenías", "ti", "tiene", "tienen", "tienes", "todo", "todos", "tu", "tus", "tuve", "tuviera", "tuvierais", "tuvieran", "tuvieras", "tuvieron", "tuviese", "tuvieseis", "tuviesen", "tuvieses", "tuvimos", "tuviste", "tuvisteis", "tuviéramos", "tuviésemos", "tuvo", "tuya", "tuyas", "tuyo", "tuyos", "un", "una", "uno", "unos", "vosotras", "vosotros", "vuestra", "vuestras", "vuestro", "vuestros", "y", "ya", "yo"
  ],
  english: [
    "a", "about", "above", "after", "again", "against", "all", "am", "an", "and", "any", "are", "aren't", "as", "at", "be", "because", "been", "before", "being", "below", "between", "both", "but", "by", "can't", "cannot", "could", "couldn't", "did", "didn't", "do", "does", "doesn't", "doing", "don't", "down", "during", "each", "few", "for", "from", "further", "had", "hadn't", "has", "hasn't", "have", "haven't", "having", "he", "he'd", "he'll", "he's", "her", "here", "here's", "hers", "herself", "him", "himself", "his", "how", "how's", "i", "i'd", "i'll", "i'm", "i've", "if", "in", "into", "is", "isn't", "it", "it's", "its", "itself", "let's", "me", "more", "most", "mustn't", "my", "myself", "no", "nor", "not", "of", "off", "on", "once", "only", "or", "other", "ought", "our", "ours", "ourselves", "out", "over", "own", "same", "shan't", "she", "she'd", "she'll", "she's", "should", "shouldn't", "so", "some", "such", "than", "that", "that's", "the", "their", "theirs", "them", "themselves", "then", "there", "there's", "these", "they", "they'd", "they'll", "they're", "they've", "this", "those", "through", "to", "too", "under", "until", "up", "very", "was", "wasn't", "we", "we'd", "we'll", "we're", "we've", "were", "weren't", "what", "what's", "when", "when's", "where", "where's", "which", "while", "who", "who's", "whom", "why", "why's", "with", "won't", "would", "wouldn't", "you", "you'd", "you'll", "you're", "you've", "your", "yours", "yourself", "yourselves"
  ]
};

/**
 * Main function to process the text file and group words by their stems.
 * @param {string} filename - The path to the text file to process.
 * @param {string} language - The language of the text file ('spanish' or 'english').
 */
async function app(filename: string, language: string) {
  try {
    const file_contents = await readFile(filename, { encoding: 'utf8' });

    // Split the file contents into words
    const words = file_contents.split(/\s+/);

    // Initialize the stemmer based on the language
    const stemmer = language === 'spanish' ? natural.PorterStemmerEs : natural.PorterStemmer;

    // Filter stop words and apply stemming
    const stemmedFreqs: { [key: string]: { count: number, words: { [key: string]: number } } } = {};
    for (const word of words) {
      const lowerWord = word.toLowerCase();
      if (!stopWords[language].includes(lowerWord)) {
        const stemmedWord = stemmer.stem(lowerWord);
        if (stemmedFreqs[stemmedWord]) {
          stemmedFreqs[stemmedWord].count += 1;
          if (stemmedFreqs[stemmedWord].words[lowerWord]) {
            stemmedFreqs[stemmedWord].words[lowerWord] += 1;
          } else {
            stemmedFreqs[stemmedWord].words[lowerWord] = 1;
          }
        } else {
          stemmedFreqs[stemmedWord] = { count: 1, words: { [lowerWord]: 1 } };
        }
      }
    }

    // Filter words with more than one occurrence and sort by frequency
    const filteredAndSorted = Object.fromEntries(
      Object.entries(stemmedFreqs)
        .filter(([, { count }]) => count > 1)
        .sort(([, a], [, b]) => b.count - a.count)
    );

    // Write the result to a JSON file
    await writeFile("results_stemmed.json", JSON.stringify(filteredAndSorted, null, 2));
    console.log("File written successfully");
  } catch (error) {
    console.error("An error occurred:", error);
  }
}

// Get arguments from the command line
const [,, filename, language] = process.argv;

// Validate arguments
if (!filename || !language) {
  console.error("Usage: node group_words.js <filename> <language>");
  process.exit(1);
}

// Run the app with the provided arguments
app(filename, language);