# Configuration

## Environment Variables

### Github
Github presently requires both a uses auth details, and an attached application respective auth tokens. The application settings may be found at [github.com/settings/applications/new](https://github.com/settings/applications/new)

```
GITHUB_ADMIN_USER
GITHUB_ADMIN_USER_PASSWORD
GITHUB_REDIRECT_URL
GITHUB_CLIENT_ID
GITHUB_SECRET
```

### Stripe
A stripe testing account may be freely signed up for over at [dashboard.stripe.com/register](https://dashboard.stripe.com/register). By default your account will be set to testing mode, unless you choice to activate it. Once your account is created your going to want to create the following plans to match what coderwall currently provides, as defined below. Finally [dashboard.stripe.com/account/apikeys](https://dashboard.stripe.com/account/apikeys) will provide test keys for you to use.

Set your `STRIPE_PUBLISHABLE_KEY` and `STRIPE_SECRET_KEY` in the `.env` file.

You will also need to create the recurring billing plans on Stripe. You can do this by hand (e.g. in the Stripe admin dashboard), or via the rails console. Use `vagrant ssh` to connect to the Rails console, and issue the following command:

`Plan.all.each { |p| p.register_on_stripe }`

You can verify that your Stripe account is configured correctly by registering a new team in development and granting it an upgraded team level.

[How to verify that Stripe is configured correctly](https://www.evernote.com/shard/s13/sh/9f7bb4ab-087b-4557-a35e-91b70812a921/582a7335834b8254020316760621165b/deep/0/A-simple-&-engaging-way-to-turn-your-organizations--best-qualities-into-an-engineer-magnet-and-Error-when-attempting-to-join-a-team-instead-of-create-a-team----391---Coderwall---Assembly.png)
