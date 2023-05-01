# Changelog

## [0.6.2](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.6.1...v0.6.2) (2023-05-01)


### Bug Fixes

* PGO swapping did not set non support to 0 ([144b9dd](https://github.com/semiotic-ai/SemioticOpt.jl/commit/144b9ddcc1db13da68d763d80f826b1fb7758788))

## [0.6.1](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.6.0...v0.6.1) (2023-05-01)


### Bug Fixes

* Iteration count starts at 1 instead of 0 ([f84df60](https://github.com/semiotic-ai/SemioticOpt.jl/commit/f84df60ddba593c5d2dcb57dc7aef72f1c536eec))

# [0.6.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.5.2...v0.6.0) (2023-05-01)


### Bug Fixes

* Post-iteration hook applied after first iter ([450c5e7](https://github.com/semiotic-ai/SemioticOpt.jl/commit/450c5e7f178de45bd770783066c5fe2499ceb6c9))


### Features

* Logger to store data in a vector ([27b07c2](https://github.com/semiotic-ai/SemioticOpt.jl/commit/27b07c283f953d13c62939b3d96bd96402ca83f4))

## [0.5.2](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.5.1...v0.5.2) (2023-04-17)


### Bug Fixes

* Correct output type of simplex projection ([912cefe](https://github.com/semiotic-ai/SemioticOpt.jl/commit/912cefe4833d4b999c7720e9b7a9e849807392dd))
* Use round down when doing bigfloat to float ([d070043](https://github.com/semiotic-ai/SemioticOpt.jl/commit/d070043ffe14b6c643650663d2d42e2b0db4bb8a))

## [0.5.1](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.5.0...v0.5.1) (2023-04-17)


### Bug Fixes

* force exact numeric sum - simplex projection ([97a5703](https://github.com/semiotic-ai/SemioticOpt.jl/commit/97a5703ba341c06af7f3ea6bbb77b209cd21e7b7))

# [0.5.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.4.0...v0.5.0) (2023-04-12)


### Features

* Compute best swap across all supports ([e69aa73](https://github.com/semiotic-ai/SemioticOpt.jl/commit/e69aa7301d32d2880882e4c3a3564908d9a91784))
* Compute the possible supports per iteration ([ea58b66](https://github.com/semiotic-ai/SemioticOpt.jl/commit/ea58b66ac4e362352718542374279b628d2a8f15))
* Get current support <= length kmax ([d72824f](https://github.com/semiotic-ai/SemioticOpt.jl/commit/d72824f1f2cc1403088d65cf1e14f8694eead5be))
* Implement the inner loop of PGO ([4dc8c25](https://github.com/semiotic-ai/SemioticOpt.jl/commit/4dc8c257684b866aa0c810936eef9f220d08d235))
* Implemented the PGO type and one iteration ([7a68378](https://github.com/semiotic-ai/SemioticOpt.jl/commit/7a68378691638c9803a587bf178924ac73a2f5e6))
* PGOOptFunction type enabling inner loop opt ([ede217f](https://github.com/semiotic-ai/SemioticOpt.jl/commit/ede217f9e7082aea5955cdf286a32e65977428d7))


### Performance Improvements

* Remove bounds checking on possiblesupports ([67cf58e](https://github.com/semiotic-ai/SemioticOpt.jl/commit/67cf58e7360d0a300bb5414fd608d4de5615b72d))
* Use native column-major rather than adjoints ([c20c745](https://github.com/semiotic-ai/SemioticOpt.jl/commit/c20c74563b2a921b3a6318b75da2df31b54d97ca))

# [0.4.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.3.0...v0.4.0) (2023-04-04)


### Features

* repeat without diag function ([295ddfd](https://github.com/semiotic-ai/SemioticOpt.jl/commit/295ddfdb11df79b0c63df7022327528327dac75d))

# [0.3.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.2.0...v0.3.0) (2023-04-04)


### Features

* vector helper functions ([ad7f787](https://github.com/semiotic-ai/SemioticOpt.jl/commit/ad7f7874016ef5a7159e065234d3941135cfe9fc))

# [0.2.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.1.0...v0.2.0) (2023-01-06)


### Features

* step size function ([a6c6abe](https://github.com/semiotic-ai/SemioticOpt.jl/commit/a6c6abed0932bb49b2f4195234292d8791467dcb))

# [0.1.0](https://github.com/semiotic-ai/SemioticOpt.jl/compare/v0.0.0...v0.1.0) (2022-10-31)


### Features

* Gradient Descent, Proj Grad Desc, Halpern ([b37a0c3](https://github.com/semiotic-ai/SemioticOpt.jl/commit/b37a0c3788e9c952d99d3a133a5d800634ee46c6))
