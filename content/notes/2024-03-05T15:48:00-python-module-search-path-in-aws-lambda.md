---
title: python module search path in aws lambda
date: 2024-03-05T15:48:00Z
slug: python-module-search-path-in-aws-lambda
tags:
- python
- aws
- lambda
---

When you use an import statement in your code, the Python runtime searches the directories in its search path until it finds the module or package. By default, the runtime searches the `$LAMBDA_TASK_ROOT` (`/var/task`) directory first. If you include a version of a runtime-included library in your image, your version will take precedence over the version that's included in the runtime.

Other steps in the search path depend on which version of the Lambda base image for Python you're using:

- **Python 3.11 and later**: Runtime-included libraries and pip-installed libraries are installed in the /var/lang/lib/python3.11/site-packages directory. This directory has precedence over /var/runtime in the search path. You can override the SDK by using pip to install a newer version. You can use pip to verify that the runtime-included SDK and its dependencies are compatible with any packages that you install.

- **Python 3.8-3.10**: Runtime-included libraries are installed in the /var/runtime directory. Pip-installed libraries are installed in the /var/lang/lib/python3.x/site-packages directory. The /var/runtime directory has precedence over /var/lang/lib/python3.x/site-packages in the search path.

You can see the full search path for your Lambda function by adding the following code snippet.

```python
import sys
      
search_path = sys.path
print(search_path)
```

# Ref
- [Deploy Python Lambda functions with container images - AWS Lambda](https://docs.aws.amazon.com/lambda/latest/dg/python-image.html)

