import Foundation
import ZIPFoundation

// Parse EPUB files
class EpubParser {

    // Import all EPUB books from bundle
    static func importEpubsFromBundle() -> [Book] {
        var importedBooks: [Book] = []
        var epubURLs: [URL] = []

        if let rootURLs = Bundle.main.urls(forResourcesWithExtension: "epub", subdirectory: nil) {
            epubURLs.append(contentsOf: rootURLs)
        }

        if let booksURLs = Bundle.main.urls(forResourcesWithExtension: "epub", subdirectory: "Books") {
            epubURLs.append(contentsOf: booksURLs)
        }

        epubURLs = Array(Set(epubURLs))

        print("EPUB FOUND COUNT:", epubURLs.count)

        for url in epubURLs {
            print("EPUB FOUND:", url.lastPathComponent)

            if let book = parseEpub(url: url) {
                importedBooks.append(book)
                print("EPUB IMPORTED:", book.title, "| Category:", book.category)
            } else {
                print("EPUB FAILED:", url.lastPathComponent)
            }
        }

        return importedBooks
    }

    // Parse a single EPUB file
    static func parseEpub(url: URL) -> Book? {
        let fileManager = FileManager.default
        let tempFolder = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)

        do {
            try fileManager.createDirectory(
                at: tempFolder,
                withIntermediateDirectories: true
            )

            try fileManager.unzipItem(at: url, to: tempFolder)

            let containerURL = tempFolder
                .appendingPathComponent("META-INF")
                .appendingPathComponent("container.xml")

            let containerXML = try String(contentsOf: containerURL, encoding: .utf8)

            guard let opfPath = extractOPFPath(from: containerXML) else {
                try? fileManager.removeItem(at: tempFolder)
                return nil
            }

            let opfURL = tempFolder.appendingPathComponent(opfPath)
            let opfFolder = opfURL.deletingLastPathComponent()

            let opfXML = try String(contentsOf: opfURL, encoding: .utf8)

            let title = extractTag("dc:title", from: opfXML)
                ?? url.deletingPathExtension().lastPathComponent

            let author = extractTag("dc:creator", from: opfXML)
                ?? "Unknown Author"

            let subjects = extractSubjects(from: opfXML)
            let category = subjects.first ?? "Uncategorized"

            let description = extractDescription(from: opfXML)

            let coverData = extractCoverData(from: opfXML, opfFolder: opfFolder)

            let chapterPaths = extractChapterPaths(from: opfXML)

            var chapters: [String] = []

            for chapterPath in chapterPaths {
                let chapterURL = opfFolder.appendingPathComponent(chapterPath)

                if let html = try? String(contentsOf: chapterURL, encoding: .utf8) {
                    let text = cleanHTML(html)

                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        chapters.append(text)
                    }
                }
            }

            try? fileManager.removeItem(at: tempFolder)

            guard !chapters.isEmpty else {
                return nil
            }

            return Book(
                title: title,
                author: author,
                category: category,
                coverName: "book.closed.fill",
                coverData: coverData,
                description: description,
                chapters: chapters,
                wordCount: chapters.joined().count,
                progress: 0.0
            )

        } catch {
            print("EPUB import error:", error)
            try? fileManager.removeItem(at: tempFolder)
            return nil
        }
    }

    // Extract OPF file path
    private static func extractOPFPath(from xml: String) -> String? {
        let pattern = #"full-path="([^"]+)""#

        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(
                in: xml,
                range: NSRange(xml.startIndex..., in: xml)
              ),
              let range = Range(match.range(at: 1), in: xml) else {
            return nil
        }

        return String(xml[range])
    }

    // Extract XML tag content
    private static func extractTag(_ tag: String, from xml: String) -> String? {
        let pattern = #"<\#(tag)[^>]*>(.*?)</\#(tag)>"#

        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ),
        let match = regex.firstMatch(
            in: xml,
            range: NSRange(xml.startIndex..., in: xml)
        ),
        let range = Range(match.range(at: 1), in: xml) else {
            return nil
        }

        return cleanMetadataText(String(xml[range]))
    }

    // Extract book description
    private static func extractDescription(from xml: String) -> String {
        if let description = extractTag("dc:description", from: xml),
           !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return description
        }

        if let description = extractTag("description", from: xml),
           !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return description
        }

        return "No description available."
    }

    // Extract book categories
    private static func extractSubjects(from xml: String) -> [String] {
        let pattern = #"<dc:subject[^>]*>(.*?)</dc:subject>"#

        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive, .dotMatchesLineSeparators]
        ) else {
            return []
        }

        let matches = regex.matches(
            in: xml,
            range: NSRange(xml.startIndex..., in: xml)
        )

        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: xml) else {
                return nil
            }

            let subject = cleanMetadataText(String(xml[range]))
            return subject.isEmpty ? nil : subject
        }
    }

    // Extract chapter file paths
    private static func extractChapterPaths(from opf: String) -> [String] {
        let pattern = #"<item[^>]*href="([^"]+\.(xhtml|html|htm))"[^>]*>"#

        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]
        ) else {
            return []
        }

        let matches = regex.matches(
            in: opf,
            range: NSRange(opf.startIndex..., in: opf)
        )

        return matches.compactMap { match in
            guard let range = Range(match.range(at: 1), in: opf) else {
                return nil
            }

            return String(opf[range])
        }
    }

    // Extract cover image data
    private static func extractCoverData(from opf: String, opfFolder: URL) -> Data? {
        var coverID: String?

        let metaPattern = #"<meta[^>]*name="cover"[^>]*content="([^"]+)""#

        if let regex = try? NSRegularExpression(pattern: metaPattern, options: [.caseInsensitive]),
           let match = regex.firstMatch(in: opf, range: NSRange(opf.startIndex..., in: opf)),
           let range = Range(match.range(at: 1), in: opf) {
            coverID = String(opf[range])
        }

        if let coverID {
            let escapedCoverID = NSRegularExpression.escapedPattern(for: coverID)

            let itemPattern1 = #"<item[^>]*id="\#(escapedCoverID)"[^>]*href="([^"]+)""#
            if let href = extractFirstMatch(pattern: itemPattern1, from: opf) {
                let coverURL = opfFolder.appendingPathComponent(href)
                if let data = try? Data(contentsOf: coverURL) {
                    return data
                }
            }

            let itemPattern2 = #"<item[^>]*href="([^"]+)"[^>]*id="\#(escapedCoverID)""#
            if let href = extractFirstMatch(pattern: itemPattern2, from: opf) {
                let coverURL = opfFolder.appendingPathComponent(href)
                if let data = try? Data(contentsOf: coverURL) {
                    return data
                }
            }
        }

        let propertyPattern = #"<item[^>]*href="([^"]+)"[^>]*properties="[^"]*cover-image[^"]*""#

        if let href = extractFirstMatch(pattern: propertyPattern, from: opf) {
            let coverURL = opfFolder.appendingPathComponent(href)

            if let data = try? Data(contentsOf: coverURL) {
                return data
            }
        }

        let imagePattern = #"<item[^>]*href="([^"]+\.(jpg|jpeg|png|webp))"[^>]*>"#

        if let href = extractFirstMatch(pattern: imagePattern, from: opf) {
            let coverURL = opfFolder.appendingPathComponent(href)

            if let data = try? Data(contentsOf: coverURL) {
                return data
            }
        }

        return nil
    }

    // Extract first regex match
    private static func extractFirstMatch(pattern: String, from text: String) -> String? {
        guard let regex = try? NSRegularExpression(
            pattern: pattern,
            options: [.caseInsensitive]
        ),
        let match = regex.firstMatch(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ),
        let range = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[range])
    }

    // Clean HTML content
    private static func cleanHTML(_ html: String) -> String {
        var text = html

        text = text.replacingOccurrences(
            of: #"<script[\s\S]*?</script>"#,
            with: "",
            options: .regularExpression
        )

        text = text.replacingOccurrences(
            of: #"<style[\s\S]*?</style>"#,
            with: "",
            options: .regularExpression
        )

        text = text.replacingOccurrences(
            of: #"<[^>]+>"#,
            with: "",
            options: .regularExpression
        )

        text = decodeHTMLEntities(text)

        text = text.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Clean metadata text
    private static func cleanMetadataText(_ text: String) -> String {
        var result = text

        result = decodeHTMLEntities(result)

        result = result.replacingOccurrences(
            of: #"<br\s*/?>"#,
            with: "\n",
            options: [.regularExpression, .caseInsensitive]
        )

        result = result.replacingOccurrences(
            of: #"</p>"#,
            with: "\n\n",
            options: [.regularExpression, .caseInsensitive]
        )

        result = result.replacingOccurrences(
            of: #"<[^>]+>"#,
            with: "",
            options: .regularExpression
        )

        result = decodeHTMLEntities(result)

        result = result.replacingOccurrences(
            of: #"\n\s*\n\s*\n+"#,
            with: "\n\n",
            options: .regularExpression
        )

        return result.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // Decode HTML entities
    private static func decodeHTMLEntities(_ text: String) -> String {
        var result = text

        let entities: [String: String] = [
            "&nbsp;": " ",
            "&amp;": "&",
            "&quot;": "\"",
            "&#39;": "'",
            "&apos;": "'",
            "&lt;": "<",
            "&gt;": ">",
            "&mdash;": "—",
            "&ndash;": "–",
            "&lsquo;": "‘",
            "&rsquo;": "’",
            "&ldquo;": "“",
            "&rdquo;": "”"
        ]

        for (entity, value) in entities {
            result = result.replacingOccurrences(of: entity, with: value)
        }

        return result
    }
}
