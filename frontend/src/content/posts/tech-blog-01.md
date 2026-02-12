---
title: "[github hardening] signing commits with ssh keys"
author: "elmouatassim"
date: "2026-02-06"
summary: "how to configure signed commits in github using your authentication ssh key?"
tags: [
    "tech",
    "github",
    "hardening",
    "security",
]
categories: [
    "tech",
    "hardening"
]
id: "tech-blog-01"
series: ["tech", "github hardening"]
---

in this serie, the goal is to share my experience about hardening github while creating a very simple blog. this one, yes! the one you are reading :)

i decided to move my blog from wordpress to learn how to build one by myself for less than 1€ a month! also, having ads on the free plan of wordpress was a bit annoying. so this is it, i will cover during this serie of posts how to host static and dynamic content and also how to deploy it on your own server, **securely**.

but where to host your blog source code? for me, the best solution is github. it is like the social network of code geeks.
so first, let's see how to configure **commit signing** in github.

## why sign your github commits?

commit signing is an important security practice that verifies the authenticity of your code contributions. when you sign a commit, you're proving that the code came from you and wasn't tampered with. github displays a "Verified" badge next to signed commits, building trust in your repository's history.

## what risk are we covering here?

a classic scenario we want to handle using commits' signing is when github credentials of a contributor are compromised.
here the hacker will be able to push commits to repositories where the hacked developer is authorized to push code.
this can lead to introducing backdoors within a code base if the changes get approved and merged.

this can be prevented using signed commits.
in the following sections, i'll walk you through configuring signed commits using an ssh key that you already use for authentication. eliminating the need to manage yet another key pair on your machine.

## generate ssh key pair on macOS

if you don't already have an ssh key pair, follow these steps to generate one on macOS:

### check for existing key

first, verify if you already have an ssh key:

```bash
ls -la ~/.ssh/
```

if you see `id_rsa` and `id_rsa.pub`, you already have a key pair and can skip to **next section**.

### generate a key pair on macOS

if you don't have a ssh key, generate one using rsa-4096 (strong algorithm):

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/id_rsa
```

when prompted, press **Enter** twice to skip the passphrase (or enter one if you prefer):

### add private key to ssh agent locally

on macOS, add your **private key** to the ssh agent so it's available for use and make sure it is readable only by your identity

```bash
chmod 0600 ~/.ssh/id_rsa
ssh-add --apple-use-keychain ~/.ssh/id_rsa
```

You should see:
```
Identity added: /Users/your_username/.ssh/id_rsa
```

### add public key to github for signing    

copy your public key to your clipboard:

```bash
cat ~/.ssh/id_rsa.pub
```

then:
1. go to [GitHub Settings → SSH and GPG keys](https://github.com/settings/keys)
2. click **New SSH key**
3. paste your key and give it a descriptive title (e.g., "MacBook Air SSH key")
4. select in **Key type** the value **Signing key**
4. click **Add SSH key**

## configure git to use your ssh key for signing

tell git to use your ssh key for signing commits:

```bash
git config --global user.signingkey ~/.ssh/id_rsa.pub
git config --global gpg.format ssh
git config --global commit.gpgsign true

# these are to configure properly the user

git config --global user.name your_username
git config --global user.email your_email@example.com
git config --global push.autosetupremote true
```

now you can sign commits. if you enabled automatic signing, commits are signed by default:

```bash
git commit -m "my signed commit"
```

## key benefits

✅ **single key**: reuse your existing ssh authentication key. no separate gpg key needed.
✅ **built-in verification**: gitHub automatically verifies signatures against your registered ssh keys.
✅ **trustworthy history**: the "Verified" badge on commits demonstrates code authenticity.
✅ **simple setup**: minimal configuration compared to gpg signing.
