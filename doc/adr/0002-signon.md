# 2. signon

Date: 2018-06-22

## Status

Accepted

## Context

Users must authenticate before using the Publish Data app. An authenticated user can belong to many organisations, of which one of these is their primary organisation e.g. for creating datasets.

When an unauthenticated user goes to any page of the app, they are redirected to the home page, which asks them to 'Sign in' or 'Create an account'. Once a user is logged in, they will be redirected to their requested page, or the tasks page.

Before this work started, we were planning to roll our own internal user management system, for which some initial work was completed. From this initial work we concluded that making our own custom solution would involve a lot of effort.

GOV.UK publishing apps use a single signon service called [GOV.UK Signon](https://github.com/alphagov/signon), which provides a standardised mechanism for user authentication and permission management, including a [rails adapter](https://github.com/alphagov/gds-sso). We think using GOV.UK Signon will require less implementation effort, as well as reduce support issues by re-using an established part of the GOV.UK platform.

## Decision

We will replace our custom user management system with GOV.UK Signon and re-address permission and organisation assignment in later work. Authentication for each environment will be controlled by the instance of GOV.UK Signon running in the corresponding environment.

## Consequences

The user model is now dictated by [GDS SSO](https://github.com/alphagov/gds-sso) as opposed to [devise](https://github.com/plataformatec/devise) and the link bearing the user's name now goes to their GOV.UK Signon dashboard. It turns out this has no effect on the remaining app features.

When a user navigates to the home page, they will still see the old page prompting them to sign in, which will then take them to GOV.UK Signon. If the user navigates to any other page, they will be redirected straight to GOV.UK Signon, which is an unfortunate consequence of using the [GDS SSO](https://github.com/alphagov/gds-sso) adapter.

All of the user management features have been removed from the app, including the admin interface and the process for creating new accounts. We can manage who can login to the app using GOV.UK Signon, although every user will have the same level of access. We will fix the permission model in later work.

When a user logs in, we attempt to find a legacy organisation with a `govuk_content_id` that matches the one specified by GOV.UK Signon, and raise an error if this fails. This only works for a few organisations, as there is no simple mapping from GOV.UK Signon organisations to our legacy organisations. This and the issue of hierarchy will be addressed in later work.
