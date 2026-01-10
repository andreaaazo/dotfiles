"""File to generate luminance steps from sigmoid."""

import math


def sigmoid(x: float, slope: float) -> float:
    """Sigmoid function to map input to output.

    Sigmoid domain is R -> (0, 1).

    :param x: Input value
    :param k: Steepness of the curve
    come cr
    :return: Mapped output value
    """
    return 1 / (1 + math.exp(-slope * x))


def get_sigmoid_domain_bounds(threshold: float, k: float) -> list[float]:
    """Generate sigmoid domain to linearize the steps.

    The domain [-x, x] defines the range of the steps from the sigmoid function.

    :param a: Slope threshold to define domain limits
    :param k: Steepness of the curve
    """
    if threshold >= k / 4:
        raise ValueError("Threshold")

    return [
        math.log(
            (-2 * threshold + k + math.sqrt(k**2 - 4 * threshold * k)) / (2 * threshold)
        )
        / -k,
        math.log(
            (-2 * threshold + k - math.sqrt(k**2 - 4 * threshold * k)) / (2 * threshold)
        )
        / -k,
    ]


def linear_map(x: float, start: float, end: float) -> float:
    """Linear mapping from [start, end] to [0, 1].

    :param x: Input value
    :param bounds: List of two floats defining the input bounds

    :return: Mapped output value
    """
    return start + (x * (end - start))


def generate_luminance_steps(
    threshold: float, steepness: float, num_steps: int
) -> list[float]:
    """Generate luminance steps from sigmoid function.

    :param threshold: Slope threshold to define domain limits
    :param steepness: Steepness of the curve
    :param num_steps: Number of luminance steps to generate_sigmoid_domain
    :return: List of luminance steps
    """
    bounds = get_sigmoid_domain_bounds(threshold, steepness)
    print("Sigmoid Domain Bounds:", bounds)
    steps: list[float] = []

    min_y = sigmoid(bounds[0], steepness)
    max_y = sigmoid(bounds[1], steepness)

    for i in range(num_steps):
        lin_value = linear_map(i / (num_steps - 1), bounds[0], bounds[1])
        sigmoid_value = sigmoid(lin_value, steepness)
        normalized_value = 1 - ((sigmoid_value - min_y) / (max_y - min_y))
        luminance_step = round(normalized_value, 5)
        steps.append(luminance_step)

    return steps


def get_min_delta(steps: list[float]) -> float:
    """Get the minimum delta between consecutive steps."""
    min_diff = 1.0

    for i in range(len(steps) - 1):
        diff = abs(steps[i] - steps[i + 1])
        min_diff = min(min_diff, diff)
    return min_diff


def optimize_parameters(num_steps: int, target_jnd: float, steepness: float) -> tuple:
    """Optimize threshold to achieve target JND between steps."""
    current_threshold = 0.0001

    max_iterations = 100_000

    for _ in range(max_iterations):
        steps = generate_luminance_steps(current_threshold, steepness, num_steps)
        min_delta = get_min_delta(steps)

        if min_delta >= target_jnd:
            return steps, current_threshold, steepness, min_delta

        current_threshold += 0.0001

    return None, 0, 0, 0


if __name__ == "__main__":
    # Example usage
    threshold_value = 1.0
    steepness_value = 1000.0
    number_of_steps = 10

    luminance_steps = generate_luminance_steps(
        threshold_value, steepness_value, number_of_steps
    )
    print("Luminance Steps:", luminance_steps)
    print("Number of Steps:", len(luminance_steps))
    print("Threshold:", threshold_value)
    print("Steepness:", steepness_value)

    final_steps, opt_threshold, opt_steepness, opt_delta = optimize_parameters(
        number_of_steps, 0.006, steepness_value
    )

    if final_steps:
        print("Optimized Luminance Steps:", final_steps)
        print("Optimized Threshold:", opt_threshold)
        print("Optimized Steepness:", opt_steepness)
        print("Optimized Minimum Delta (JND):", opt_delta)
        print("Final steps:")
        print(final_steps)
