# HexClient

This is a simple API client for the [hex.pm](https://hex.pm/) [API](https://github.com/hexpm/hex_web/blob/master/lib/hex_web/api/router.ex),
currently only able to fetch the public information not needing authentication.

So far you can:

- list packages as stream ordered by "name", "downloads", "inserted_at" or "updated_at".
- list all releases for a package.
- detailed information about a single package release.
- documentation archive download link for package release.
