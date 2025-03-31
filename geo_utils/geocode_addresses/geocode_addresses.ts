'use strict'

/*
USAGE:
node geocode_addresses.ts --file="string" --format=[json|csv]
- File: Is the path to the file which contains the address to lookup their coordinates in Google service.
- Format: Is the input file format, in order to know how to parse it.
Important: The CSV files must have header
*/

// Imports
import { readFileSync, appendFileSync, existsSync, mkdirSync } from 'fs';
import { argv } from 'yargs';
import { getJsonFromCsv } from "convert-csv-to-json";
import request from 'request';
import { config } from 'dotenv';

// Load environment variables from .env file if present
config();

// Declarations
const now: number = Date.now();
const gmap_apikey: string | undefined = process.env.GMAPS_APIKEY;
const file: string | undefined = argv.file as string;
let format: string = argv.format ? (argv.format as string).toLowerCase() : 'json'; // Default format is JSON
const output_dir: string = 'files/output';
const output_file: string = `${output_dir}/locations_${now}.json`;
let json_content: any[] = [];

// Ensure output directory exists
if (!existsSync(output_dir)) {
  mkdirSync(output_dir, { recursive: true });
}

console.log("***************************************************");
console.log("Google Maps coordinates finder started");
console.log("The results will be saved to", output_file);
console.log("The input file selected is '", file, "' and the format is '", format, "'");

// Validate input file and format
if (!file) {
  console.error("Error: File to read not specified. Script end.");
  process.exit(1);
}

if (!['csv', 'json'].includes(format)) {
  console.error("Error: Format not valid. Script end.");
  process.exit(1);
}

// Read and parse file content
try {
  const file_content: string = readFileSync(file, 'utf8');
  json_content = format === 'csv' ? getJsonFromCsv(file_content) : JSON.parse(file_content);
} catch (error) {
  console.error("Error reading or parsing file:", (error as Error).message);
  process.exit(1);
}

// Validate file content
if (!json_content || json_content.length === 0) {
  console.error("Error: Content is empty or null. Script end.");
  process.exit(1);
}

// Process each item and fetch coordinates
let increment: number = 1;
json_content.forEach((item, index) => {
  const address: string = sanitizeText(Object.values(item).join(" "));
  const query: string = escapeText(address);

  request({
    url: `https://maps.google.com/maps/api/geocode/json?address=${query}&key=${gmap_apikey}`,
    json: true
  }, (error, response, body) => {
    console.log(`Processing record #${increment}`);
    if (!error && response.statusCode === 200 && body.results.length > 0) {
      const coords = body.results[0].geometry.location;
      item.lat = coords.lat;
      item.lng = coords.lng;
      const content = JSON.stringify(item, null, 2);
      appendFileSync(output_file, `${index === 0 ? '[' : ''}${content}${index < json_content.length - 1 ? ',\n' : ']\n'}`);
    } else {
      console.error(`Error fetching coordinates for record #${increment}:`, error || body.status);
    }
    increment++;
  });
});

// Utility functions
function sanitizeText(txt: string): string {
  return txt.replace(/\s+/g, "+");
}

function escapeText(txt: string): string {
  return txt.normalize('NFD').replace(/[\u0300-\u036f]/g, "");
}