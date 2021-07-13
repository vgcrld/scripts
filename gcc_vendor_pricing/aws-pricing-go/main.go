package main

import (
	"fmt"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/pricing"
	"github.com/davecgh/go-spew/spew"
)

func main() {

	mySession := session.Must(session.NewSession())

	// Create a Pricing client with additional configuration
	svc := pricing.New(mySession, aws.NewConfig().WithRegion("us-west-2"))

	product := aws.String("AmazonEC2")

	desc, err := svc.DescribeServices(&pricing.DescribeServicesInput{ServiceCode: product})
	if err != nil {
		fmt.Println(err)
	}
	spew.Dump(desc)

}
