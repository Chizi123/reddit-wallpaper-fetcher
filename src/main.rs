use std::io::Write;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    return Ok(test_curl().await?);
    //    return Ok(test_reqwest().await?);
    // return Ok(());
}

// Headers screwy and lowercase, not working with reddit
async fn test_hyper() -> Result<(), Box<dyn std::error::Error>> {
    let client = hyper::client::Client::builder()
        .build::<_, hyper::body::Body>(hyper_tls::HttpsConnector::new());
    println!("{:#?}", client);
    let req = hyper::Request::builder()
        .method(hyper::Method::GET)
        //        .uri("https://matrix.joelg.net/_matrix/key/v2/server")
        .uri("https://www.reddit.com/r/wallpapers.json")
        // .uri("http://localhost:8080")
        .header(
            "user-agent",
            format!("{}{}", whoami::username(), whoami::devicename()),
        )
        .header("accept", "*/*")
        .body(hyper::Body::empty())?;
    println!("{:#?}", req);
    let req = client.request(req).await?;
    println!("{:#?}", req);
    let body = hyper::body::to_bytes(req.into_body()).await?;
    println!("{:#?}", body);
    let json: serde_json::Value = serde_json::from_slice(&body)?;
    println!("{:#?}", json);
    return Ok(());
}

// Headers screwy and lowercase, not working with reddit
async fn test_reqwest() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::builder()
        .user_agent(format!("{}{}", whoami::username(), whoami::devicename()))
        .build()?;
    println!("{:#?}", client);
    let resp = client
        // .get("https://www.reddit.com/r/wallpapers.json")
        .get("http://localhost:8080")
        .send()
        .await?;
    println!("{:#?}", resp);
    let body = resp.text().await?; // can replace with .json()
    println!("{:#?}", body);
    let json: serde_json::Value = body.into();
    println!("{:#?}", json);
    return Ok(());
}

// Working with reddit, unsure how to extract data
async fn test_curl() -> Result<(), Box<dyn std::error::Error>> {
    let mut client = curl::easy::Easy::new();
    client.useragent(format!("{}{}", whoami::username(), whoami::devicename()).as_str())?;
    client.url("https://joelg.net")?;
    let mut body = String::new();
    {
        let mut transfer = client.transfer();
        transfer
            .write_function(|data| {
                std::io::stdout().write_all(data).unwrap();
                // body.push_str(std::str::from_utf8(data).unwrap());
                Ok(data.len())
            })
            .unwrap();
    }
    println!("{:#?}", client);
    client.perform()?;
    println! {"{}", client.response_code()?};
    println!("{:#?}", body);
    return Ok(());
}
