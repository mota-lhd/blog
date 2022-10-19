---
title: 'A brand new blog (for free)'
author: 'Elmouatassim'
date: '2022-06-11'
summary: "How you can build a blog for free using technologies from DigitalOcean, Google Cloud, Hugo, Cloudinary, Pulumi, Github, Python and FastAPI"
tags: [
    'Tech',
    'Google Cloud',
    'DigitalOcean',
]
categories: [
    "Tech"
]
id: '5643280054222848'
series: ["Tech"]
draft: true
---

I want to share my experience while building a very simple blog. This one, yes! The one you are reading :) I decided to move my blog from wordpress because of the ads they put into my posts while using a free plan and also I discovered free solutions to build and host easily static and dynamic content. I wanted to test two of them.

## [Digital Ocean](https://cloud.digitalocean.com/)

Digital Ocean is very simple to use (yet powerful) and will let you build effective solutions to host an application. I chose the App Platform solution from their products because they offer a very interesting free-tier for hosting static content. You can build and deploy 3 static sites for free on the Starter tier.

Then I decided also to move my DNS records management on their platform, why? Easier to manage and it's free also :) So I bought a domain name on [NameCheap](https://www.namecheap.com) (because it's cheap) and just configured it to be managed on DigitalOcean.

So how am I generating this content?

## [Hugo](https://gohugo.io)

They claim to be the world's fastest framework for generating static websites. Didn't benchmark it, but looks pretty fast while testing it. I decided to go for a very [simple theme](https://github.com/nanxiaobei/hugo-paper) that I tweaked a bit.

## [Cloudinary](https://cloudinary.com)

For hosting images, I decided to use this service so I can get out of my repo the pictures and store them on a CDN (Content Delivery Network). The code repo stays light and the delivery of images is more efficient. I chose Cloudinary because it offers an interesting free tier plan. Whenever I need to show some picture on my blog, I use the following type of link:

> https://res.cloudinary.com/elmouatassim/image/upload/08/01.webp

I upload my pictures in any file format (JPEG, PNG, RAW, etc.) but when I reference an image, I change the file format to [WEBP](https://fr.wikipedia.org/wiki/WebP) and Cloudinary does the conversion for me :) I think they do it automatically when I upload an image and keep it in some kind of hot cache. Anyhow, it's quiet fast when you load a page containing transformed pictures. Why I am using WebP? It's an image compression alternative that suits well the world of the internet and does not consume too much bandwith while keeping a decent quality of the image.


## [Pulumi](https://www.pulumi.com)

To deploy on DigitalOcean I went for something automatic. But you need to perform one manual action which is authorizing DigitalOcean to watch for repository events on Github. So when you push your commits to a repo, it triggers an event to Digital Ocean who will start deploying the new version of your app. But to maintain the configuration of my app on Digital Ocean I chose an IAC (Infrastructure As Code) framework called Pulumi. You describe your configuration in the language you prefer and Pulumi makes sure it's deployed like you want it. Pulumi also detects when the configuration changes and deploys only the difference. I love [Python](https://www.python.org), so I describe my infrastructure on Digital Ocean using that language.

First you need to install Pulumi for your computer. On MAC you can do it using [brew](https://brew.sh).

```sh
brew install pulumi
```

Then you need a free account on Pulumi cloud. Once you have it, you just need to start a new project and install a provider for your cloud solution, for me it was the Digital Ocean provider.

```python
from pulumi import Config, Output, export
from pulumi_digitalocean import (
    Domain,
    Project,
    App,
    AppSpecArgs,
    DnsRecord,
    AppSpecStaticSiteArgs,
    AppSpecStaticSiteGithubArgs,
    AppSpecStaticSiteRouteArgs,
)
from pulumi.resource import ResourceOptions


config: Config = Config()
domain_name: str = config.require("main-domain")
sub_domain: str = config.require("sub-domain")
full_domain_name: str = f"{sub_domain}.{domain_name}"
```


## [Google Cloud Platform](https://cloud.google.com)

Is 