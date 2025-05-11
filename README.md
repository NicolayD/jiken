# Jiken

This library allows developers to simulate failures in their Mix applications. Different functions are configured to fail with specific errors, and revert to their normal operation after.

It is intended to be used in development, but eventually the goal is to support staging usage as well.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `jiken` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:jiken, "~> 0.0.1", only: [:dev]}
  ]
end
```

## Usage

**TODO

## Roadmap
- [ ] Pull exceptions from production and simulate them locally:
  - [ ] from AppSignal
  - [ ] from Sentry
- [ ] Collect metrics for simulated exceptions
- [ ] Support more tailored usage in staging
- [ ] Support for coordination across distributed nodes

## Inspirations

The biggest inspirations for this library are the following:
- [Mimic](https://github.com/edgurgel/mimic) - I've been using Mimic for a while now, and it's a great library.
I want to better understand it and also to apply its approach to learn more about Elixir and OTP.
- [sled simulation guide (jepsen-proof engineering)](https://sled.rs/simulation.html) - I've been reading more about distributed systems and stumbled upon this post.
I can't hide that the topic is beyond me for now, but I'm interested in going deeper into it.

## Copyright and License

Copyright (c) 2024 Nikolay Dyulgerov

This library is [MIT licensed](https://github.com/nicolayd/jiklen/blob/main/LICENSE.md). See the LICENSE.md for details.
