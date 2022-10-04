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

do_domain: Domain = Domain("personal-blog-domain", name=domain_name)
blog_project: Project = Project(
    "personal-blog-project",
    name="Personal Blog",
    description="A project to represent personal blog resources.",
    environment="Production",
    purpose="Web application",
    resources=[
        do_domain.domain_urn,
    ],
)

blog: App = App(
    "personal-blog-app",
    spec=AppSpecArgs(
        name="personal-blog-app",
        region=config.require("region"),
        domains=[{"name": full_domain_name}],
        static_sites=[
            AppSpecStaticSiteArgs(
                build_command="rm -rf ./public; hugo --minify --destination ./public",
                environment_slug="hugo",
                output_dir="./public",
                github=AppSpecStaticSiteGithubArgs(
                    branch="main",
                    deploy_on_push=True,
                    repo="mota-lhd/personal-blog",
                ),
                name="hugo-config",
                routes=[
                    AppSpecStaticSiteRouteArgs(
                        path="/",
                    )
                ],
            )
        ],
    ),
)

app_url: Output = Output.concat(
    blog.default_ingress.apply(lambda x: x.replace("https://", "")),
    ".",
)

main_domain = DnsRecord(
    "main-blog-domain",
    name=sub_domain,
    domain=do_domain.id,
    type="CNAME",
    value=app_url,
    ttl=30,
    opts=ResourceOptions(depends_on=[blog]),
)

export("blog_url", main_domain.fqdn)
