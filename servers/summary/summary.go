package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"strings"

	"golang.org/x/net/html"
)

//PreviewImage represents a preview image for a page
type PreviewImage struct {
	URL       string `json:"url,omitempty"`
	SecureURL string `json:"secureURL,omitempty"`
	Type      string `json:"type,omitempty"`
	Width     int    `json:"width,omitempty"`
	Height    int    `json:"height,omitempty"`
	Alt       string `json:"alt,omitempty"`
}

//PageSummary represents summary properties for a web page
type PageSummary struct {
	Type        string          `json:"type,omitempty"`
	URL         string          `json:"url,omitempty"`
	Title       string          `json:"title,omitempty"`
	SiteName    string          `json:"siteName,omitempty"`
	Description string          `json:"description,omitempty"`
	Author      string          `json:"author,omitempty"`
	Keywords    []string        `json:"keywords,omitempty"`
	Icon        *PreviewImage   `json:"icon,omitempty"`
	Images      []*PreviewImage `json:"images,omitempty"`
}

const headerContentType = "Content-Type"
const headerAccessControlAllowOrigin = "Access-Control-Allow-Origin"

const contentTypeJSON = "application/json"
const contentTypeText = "text/plain"

//SummaryHandler handles requests for the page summary API.
//This API expects one query string parameter named `url`,
//which should contain a URL to a web page. It responds with
//a JSON-encoded PageSummary struct containing the page summary
//meta-data.
func SummaryHandler(w http.ResponseWriter, r *http.Request) {
	/*TODO: add code and additional functions to do the following:
	- Add an HTTP header to the response with the name
	 `Access-Control-Allow-Origin` and a value of `*`. This will
	  allow cross-origin AJAX requests to your server.
	- Get the `url` query string parameter value from the request.
	  If not supplied, respond with an http.StatusBadRequest error.
	- Call fetchHTML() to fetch the requested URL. See comments in that
	  function for more details.
	- Call extractSummary() to extract the page summary meta-data,
	  as directed in the assignment. See comments in that function
	  for more details
	- Close the response HTML stream so that you don't leak resources.
	- Finally, respond with a JSON-encoded version of the PageSummary
	  struct. That way the client can easily parse the JSON back into
	  an object

	Helpful Links:
	https://golang.org/pkg/net/http/#Request.FormValue
	https://golang.org/pkg/net/http/#Error
	https://golang.org/pkg/encoding/json/#NewEncoder
	*/

	w.Header().Add(headerContentType, contentTypeJSON)
	w.Header().Add(headerAccessControlAllowOrigin, "*")

	URL := r.URL.Query().Get("url")
	if len(URL) == 0 {
		http.Error(w, "please provide url", http.StatusBadRequest)
	}
	htmlStream, err := fetchHTML(URL)
	if err != nil {
		log.Fatalf("error fetching URL %v\n", err)
	}

	summary, err := extractSummary(URL, htmlStream)
	if err != nil {
		fmt.Printf("error encoding JSON %v\n", err)
	}
	defer htmlStream.Close()
	json.NewEncoder(w).Encode(summary)

}

//fetchHTML fetches `pageURL` and returns the body stream or an error.
//Errors are returned if the response status code is an error (>=400),
//or if the content type indicates the URL is not an HTML page.
func fetchHTML(pageURL string) (io.ReadCloser, error) {
	/*TODO: Do an HTTP GET for the page URL. If the response status
	code is >= 400, return a nil stream and an error. If the response
	content type does not indicate that the content is a web page, return
	a nil stream and an error. Otherwise return the response body and
	no (nil) error.

	To test your implementation of this function, run the TestFetchHTML
	test in summary_test.go. You can do that directly in Visual Studio Code,
	or at the command line by running:
		go test -run TestFetchHTML

	Helpful Links:
	https://golang.org/pkg/net/http/#Get
	*/

	res, err := http.Get(pageURL)
	fmt.Println(pageURL)
	if err != nil {
		return nil, fmt.Errorf("error reaching page, %v", err)
	}

	if res.StatusCode >= 400 {
		return nil, fmt.Errorf("error reaching page, %v", err)
	}

	ctype := res.Header.Get("Content-Type")
	if !strings.HasPrefix(ctype, "text/html") {
		return nil, fmt.Errorf("error reaching page, %v", err)
	}

	return res.Body, nil
}

//extractSummary tokenizes the `htmlStream` and populates a PageSummary
//struct with the page's summary meta-data.
func extractSummary(pageURL string, htmlStream io.ReadCloser) (*PageSummary, error) {
	/*TODO: tokenize the `htmlStream` and extract the page summary meta-data
	according to the assignment description.

	To test your implementation of this function, run the TestExtractSummary
	test in summary_test.go. You can do that directly in Visual Studio Code,
	or at the command line by running:
		go test -run TestExtractSummary

	Helpful Links:
	https://drstearns.github.io/tutorials/tokenizing/
	http://ogp.me/
	https://developers.facebook.com/docs/reference/opengraph/
	https://golang.org/pkg/net/url/#URL.ResolveReference
	*/
	objectSummary := new(PageSummary)
	objectImageSummary := new(PreviewImage)
	tokenizer := html.NewTokenizer(htmlStream)
	for {
		tokenType := tokenizer.Next()

		if tokenType == html.ErrorToken {
			if tokenizer.Err() == io.EOF {
				return objectSummary, nil
			}
			return nil, tokenizer.Err()
		}

		token := tokenizer.Token()
		if tokenType == html.EndTagToken && "head" == token.Data {
			return objectSummary, nil
		}

		mappy := make(map[string]string)
		if len(token.Attr) > 0 {

			for _, a := range token.Attr {
				mappy[a.Key] = a.Val
			}
		}

		for _, v := range mappy {
			if v == "og:type" {
				objectSummary.Type = mappy["content"]
			} else if v == "og:url" {
				objectSummary.URL = mappy["content"]
			} else if v == "og:title" {
				objectSummary.Title = mappy["content"]
			} else if v == "og:site_name" {
				objectSummary.SiteName = mappy["content"]
			} else if v == "og:description" {
				objectSummary.Description = mappy["content"]
			} else if v == "description" && objectSummary.Description == "" {
				objectSummary.Description = mappy["content"]
			} else if v == "author" {
				objectSummary.Author = mappy["content"]
			} else if v == "keywords" {
				keywordsList := mappy["content"]
				stringSlice := strings.Split(keywordsList, ",")
				for index, element := range stringSlice {
					stringSlice[index] = strings.TrimSpace(element)
				}
				objectSummary.Keywords = stringSlice
			} else if v == "og:image" {
				objectImageSummarySlice := new(PreviewImage)
				u, _ := url.Parse(mappy["content"])
				base, _ := url.Parse(pageURL)
				resolvedURL := (base.ResolveReference(u)).String()
				objectImageSummarySlice.URL = resolvedURL
				objectSummary.Images = append(objectSummary.Images, objectImageSummarySlice)
			} else if v == "og:image:height" {
				objectSummary.Images[len(objectSummary.Images)-1].Height, _ = strconv.Atoi(mappy["content"])
			} else if v == "og:image:width" {
				objectSummary.Images[len(objectSummary.Images)-1].Width, _ = strconv.Atoi(mappy["content"])
			} else if v == "og:image:alt" {
				objectSummary.Images[len(objectSummary.Images)-1].Alt = mappy["content"]
			} else if v == "og:image:secure_url" {
				objectSummary.Images[len(objectSummary.Images)-1].SecureURL = mappy["content"]
			} else if v == "og:image:type" {
				objectSummary.Images[len(objectSummary.Images)-1].Type = mappy["content"]
			}
		}

		if "link" == token.Data {
			if len(token.Attr) > 0 {
				for _, b := range token.Attr {
					if b.Val == "icon" {
						objectSummary.Icon = objectImageSummary
					} else if b.Key == "href" {
						u, _ := url.Parse(b.Val)
						base, _ := url.Parse(pageURL)
						resolvedURL := (base.ResolveReference(u)).String()
						objectImageSummary.URL = resolvedURL

					} else if b.Key == "type" {
						objectImageSummary.Type = b.Val
					} else if b.Key == "sizes" {
						if b.Val != "any" {
							sizeList := b.Val
							sizeSlice := strings.Split(sizeList, "x")

							objectImageSummary.Width, _ = strconv.Atoi(sizeSlice[1])
							objectImageSummary.Height, _ = strconv.Atoi(sizeSlice[0])
						}

					}
				}
			}
		}

		if "title" == token.Data && tokenType == html.StartTagToken {
			tokenType = tokenizer.Next()
			if objectSummary.Title == "" {
				objectSummary.Title = tokenizer.Token().Data
			}

		}

	}

	return nil, nil
}
