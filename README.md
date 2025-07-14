-----

# Ruby Web Inspector

A simple command-line tool written in Ruby to fetch and analyze web pages. It provides a detailed summary of the HTTP response, content structure, and server information for any given URL.

-----

## Features

  - **Performance Summary**: Measures and displays the server response time.
  - **HTTP Details**: Shows the HTTP status code, message, and protocol version.
  - **Header Inspection**: Lists all response headers with special, detailed formatting for `Set-Cookie` headers.
  - **Content Analysis**: Scrapes the page for basic SEO elements like the HTML title, meta description, and the main `<h1>` heading.
  - **Resource Count**: Counts the total number of links (`<a>`) and images (`<img>`) on the page.
  - **Network Information**: Resolves the server's IP address and uses a public API to fetch its geolocation data (city, country, ISP).
  - **Batch Processing**: Can analyze multiple URLs in a single run.

-----

## Requirements

  - Ruby (\>= 2.5)
  - The `nokogiri` gem for HTML parsing.

-----

## Installation

1.  Make sure you have Ruby installed on your system.

2.  Install the required gem from your terminal:

    ```bash
    gem install nokogiri
    ```

-----

## Usage

1.  Save the script code as a file (e.g., `inspect.rb`).

2.  Make the script executable (optional but recommended):

    ```bash
    chmod +x inspect.rb
    ```

3.  Run the script from your terminal, followed by one or more URLs:

    ```bash
    ./inspect.rb https://example.com https://github.com
    ```

### Example Output

```
╔══ ANFRAGE AN: https://example.com ══════
║
╠══ ÜBERSICHT & PERFORMANCE ═══════
║  ├─ Protokoll:     HTTP/1.1
║  ├─ Status:        200 OK
║  └─ Antwortzeit:  150.78 ms
║
╠══ HEADERS ═══════════════════════
║  ├─ Content-type : text/html; charset=UTF-8
║  ├─ Etag         : "3147526947"
║  └─ Server       : ECS (ord/1234)
║
╠══ 📄 INHALTS-ANALYSE (Scraping) ══
║  ├─ HTML-Titel:     Example Domain
║  ├─ Meta-Descr.:    N/A
║  ├─ H1-Überschrift: Example Domain
║  ├─ Links (total):  1
║  └─ Bilder (total): 0
║
╠══ 🌍 NETZWERK & STANDORT ═════════
║  ├─ IP-Adresse:     93.184.216.34
║  ├─ Standort:       Norwell, Massachusetts, United States
║  ├─ Zeitzone:       America/New_York
║  └─ Provider/ISP:   ICANN
╚═══════════════════════════════════
```
