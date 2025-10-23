---
title: 'Self hosting'
author: 'Elmouatassim'
date: '2025-10-24'
summary: "How you can build basic tooling yourself, host it in Europe and not depend on big tech corporations?"
tags: [
    'Tech',
    'Hugo',
    'Docker',
    'Disco',
    'GCP',
    'Terraform',
    'Github Actions',
    'FastAPI'
]
categories: [
    "Tech"
]
id: '5643280054222848'
series: ["Tech"]
draft: false
weight: 3
---

# Still in WIP

I want to share my experience while building a very simple blog. This one, yes! The one you are reading :) I decided to move my blog from wordpress to learn how to build one by myself for less than 1€ per month! Also, having ads on the free plan of wordpress was a bit annoying. So this is it, I will cover during this series of posts how to host static and dynamic content and also how to deploy it using Terraform and secure CI/CD workflows on Github Actions.

## [Hugo](https://gohugo.io)

They claim to be the world's fastest framework for generating static websites. Didn't benchmark it, but looks pretty fast while testing it. I decided to go for a very [simple theme](https://github.com/nanxiaobei/hugo-paper) that I tweaked a bit. The proje

## [Cloudinary](https://cloudinary.com)

For hosting images, I decided to use this service so I can get out of my repo the pictures and store them on a CDN (Content Delivery Network). The code repo stays light and the delivery of images is more efficient. I chose Cloudinary because it offers an interesting free tier plan. Whenever I need to show some picture on my blog, I use the following type of link:

> https://res.cloudinary.com/elmouatassim/image/upload/08/01.webp

I upload my pictures in any file format (JPEG, PNG, RAW, etc.) but when I reference an image, I change the file format to [WEBP](https://fr.wikipedia.org/wiki/WebP) and Cloudinary does the conversion for me :) I think they do it automatically when I upload an image and keep it in some kind of hot cache. Anyhow, it's quiet fast when you load a page containing transformed pictures. Why I am using WebP? It's an image compression alternative that suits well the world of the internet and does not consume too much bandwith while keeping a decent quality of the image.

## [FastAPI](https://fastapi.tiangolo.com)

## [Docker](https://www.docker.com)

## [Terraform Cloud](https://app.terraform.io/)

To deploy on Google Cloud I went for something automatic and to maintain the configuration of my app on GCP I chose an IAC (Infrastructure As Code) framework called Terraform. You describe your configuration in their language (HCL) and Terraform makes sure it's deployed like you want it. It also detects when the configuration changes and deploys only the difference.

Then you need a free account on Pulumi cloud. Once you have it, you just need to start a new project and install a provider for your cloud solution, for me it was the Digital Ocean provider.

```python
```


## [Disco](https://disco.cloud/)

## [Github Actions](https://github.com/features/actions)

