package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os"
)

type post struct {
	created_utc float64
	data        map[string]interface{}
	subreddit   string
}

func main() {
	p := fetch()
	fmt.Println(p.created_utc, p.subreddit)
}

func fetch() post {
	client := &http.Client{}
	req, err := http.NewRequest("GET", "https://www.reddit.com/r/wallpapers.json", nil)
	if err != nil {
		panic(err)
	}
	hostname, err := os.Hostname()
	if err != nil {
		panic(err)
	}
	req.Header.Set("User-Agent", hostname)
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	fmt.Println("Response: ", resp.Status)

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	// fmt.Println(string(body))

	var j map[string]map[string][]map[string]map[string]interface{}
	json.Unmarshal(body, &j)

	// a := j["data"].(map[string]interface{})
	// b := a["children"].([]interface{})
	// c := b[1].(map[string]interface{})
	// d := c["data"].(map[string]interface{})
	// e := d["created_utc"].(float64)
	// e := j["data"]["children"][1]["data"]["created_utc"].(float64)
	// fmt.Println("created_utc: ", e)
	return post{created_utc: j["data"]["children"][1]["data"]["created_utc"].(float64), subreddit: j["data"]["children"][1]["data"]["subreddit"].(string), data: j["data"]["children"][1]["data"]}
}
