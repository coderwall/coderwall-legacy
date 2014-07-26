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
```
# TODO: Provide Plan Details
```

```
STRIPE_PUBLISHABLE_KEY
STRIPE_SECRET_KEY
```