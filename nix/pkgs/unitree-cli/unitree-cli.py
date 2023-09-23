from typing import Tuple
# import sys
# from pathlib import Path
import time

import click
from loguru import logger
import numpy as np

from pyunitree import Go1, SensorData


NEUTRAL_STANCE_QPOS = [
    -0.1, 0.8, -1.5,  # Front Right
    0.1,  0.8, -1.5,  # Front Left
    -0.1, 0.8, -1.5,  # Rear Right
    0.1,  0.8, -1.5,  # Rear Left
]


class Preset(object):
    def __init__(self, agent: Go1, decimation: int = 4):
        self._agent = agent
        self._decimation = decimation
        self._dt = agent.timestep()

    def run(self):
        obs: SensorData = self._agent.read_sensor()

        while True:
            t0 = time.time()
            act, done = self._step(obs)
            if done:
                break

            self._agent.send_action(act)
            for i in range(self._decimation):
                time.sleep(t0 + self._dt * i - time.time(), 0)
                obs = self._agent.read_sensor()

    def _step(self, obs: SensorData) -> Tuple[np.ndarray, bool]:
        return np.array(NEUTRAL_STANCE_QPOS), False


class PushUp(Preset):
    def __init__(self, agent: Go1):
        super().__init__(agent)
        self._step_count = 0
        self._goals = []

    def _step(self, obs: SensorData) -> Tuple[np.ndarray, bool]:
        pass


@click.group()
def app():
    pass


@app.command
@click.option(
    "--preset", default="push-up",
)
@click.option(
    "--plot", default="",
)
def perform(preset: str, plot: str):
    # if preset not in PRESETS:
    #     logger.critical(f"No registered preset called '{preset}'")
    #     sys.exit(-1)

    logger.info("Make sure the robot is in stable position and "
                "press enter ...")
    # transition_to_neutral_stance()

    # PRESETS[preset]().run()


@app.command
def listen():
    agent = Go1(500)
    while True:
        obs: SensorData = agent.read_sensor()
        logger.info(
            f"FR: {obs.pos[0]:.3f} {obs.pos[1]:.3f} {obs.pos[2]:.3f} | "
            f"FL: {obs.pos[3]:.3f} {obs.pos[4]:.3f} {obs.pos[5]:.3f} | "
            f"RR: {obs.pos[6]:.3f} {obs.pos[7]:.3f} {obs.pos[8]:.3f} | "
            f"RL: {obs.pos[9]:.3f} {obs.pos[10]:.3f} {obs.pos[11]:.3f}")
        time.sleep(1.0)


if __name__ == "__main__":
    app()
