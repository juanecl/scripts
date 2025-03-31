# Geocode Addresses

A script to fetch coordinates for addresses using the Google Maps Geocoding API. This script reads addresses from a specified file (in JSON or CSV format), fetches their coordinates, and saves the results to an output file.

## Usage

```bash
npm start -- --file="path/to/input/file" --format=[json|csv]

--file: Path to the input file containing addresses.
--format: Format of the input file (json or csv). Default is json.

Environment Variables
<vscode_annotation details='%5B%7B%22title%22%3A%22hardcoded-credentials%22%2C%22description%22%3A%22Embedding%20credentials%20in%20source%20code%20risks%20unauthorized%20access%22%7D%5D'>-</vscode_annotation> GMAPS_APIKEY: Your Google Maps API key.

