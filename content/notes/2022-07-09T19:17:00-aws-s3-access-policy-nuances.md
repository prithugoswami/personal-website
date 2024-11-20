---
title: AWS S3 access policy nuances
date: 2022-07-09T19:17:00Z
slug: aws-s3-access-policy-nuances
tags:
- aws
---

If you want to give access to everything in the bucket (objects) make sure the
resource arn for the s3 bucket must also have a `/*` indicating all objects in the bucket

```
"Resource": [
  "arn:aws:s3:::BUCKET-NAME",
]
```
This one won't give access to objects in the bucket, the following one will.

```
"Resource": [
  "arn:aws:s3:::BUCKET-NAME",
  "arn:aws:s3:::BUCKET-NAME/*"
]
```

- There is a difference between these two resources. One is the bucket
  itself (`arn:aws:s3:::BUCKET-NAME`) and tthe other refers to the objects in
  the bucket `arn:aws:s3:::BUCKET-NAME/*`
- `ListObjects` API requires `s3:ListBucket` permission ***on*** the
  bucket. [^1]
- Another thing to keep in mind is that only if you have `s3:ListBucket`
  permission on the bucket then you get a 404 otherwise you get a 403, which
  makes sense, since you are not allowed to list the contents of a bucket, but
  only access them via the key.

  From the [docs](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html)
  
  > Permissions
  > 
  > You need the relevant read object (or version) permission for this operation.
  > For more information, see Specifying Permissions in a Policy. If the object
  > that you request doesn’t exist, the error that Amazon S3 returns depends on
  > whether you also have the s3:ListBucket permission.
  > 
  > If you have the s3:ListBucket permission on the bucket, Amazon S3 returns an
  > HTTP status code 404 (Not Found) error.
  > 
  > If you don’t have the s3:ListBucket permission, Amazon S3 returns an HTTP
  > status code 403 ("access denied") error.

### Read More
- [AccessDenied for ListObjects for S3 bucket when permissions are s3:\*](https://stackoverflow.com/questions/38774798/accessdenied-for-listobjects-for-s3-bucket-when-permissions-are-s3)

[^1]: https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectsV2.html
