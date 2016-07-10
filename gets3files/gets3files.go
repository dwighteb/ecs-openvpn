package main

import (
	"flag"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/s3/s3manager"
	"log"
	"os"
)

func main() {

	regionPtr := flag.String("region", "us-east-1", "AWS region to use")
	bucketPtr := flag.String("bucket", "foo-bucket", "S3 Bucket to download from")
	directoryPtr := flag.String("directory", "/", "Directory within S3 Bucket to download from")

	flag.Parse() // List of files to download on the command line

	for _, filename := range flag.Args() {
		file, err := os.Create(filename)
		if err != nil {
			log.Fatal("Failed to create file", err)
		}
		defer file.Close()

		downloader := s3manager.NewDownloader(session.New(&aws.Config{Region: aws.String(*regionPtr)}))
		numBytes, err := downloader.Download(file,
			&s3.GetObjectInput{
				Bucket: aws.String(*bucketPtr),
				Key:    aws.String(*directoryPtr + filename),
			})
		if err != nil {
			fmt.Println("Failed to download file", err)
			return
		}

		fmt.Println("Downloaded file", file.Name(), numBytes, "bytes")
	}
}
