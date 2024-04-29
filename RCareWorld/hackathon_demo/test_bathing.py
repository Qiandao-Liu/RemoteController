from pyrcareworld.envs import RCareWorld
from pyrcareworld.attributes import sponge_attr
import random
import json
import numpy as np

from flask import Flask
from flask import jsonify
from flask import request
from threading import Thread
from queue import Queue
import time

# command queue
command_queue = Queue()

# backend functions
app = Flask(__name__)

# Initialize the RCareWorld environment
env = RCareWorld(
    executable_file="/Users/qiandaoliu/RCareWorld/hackathon_demo/Build/Bathing/Mac/bathing.app"
)
robot = env.create_robot(
    id=123456, gripper_list=[123456], robot_name="stretch3", base_pos=[0, 0, 0]  # robot
)
robot_base = env.create_robot(id = 12346, robot_name = 'mobile_base', base_pos = [0, 0, 1])  # robot base
cube = env.create_object(id=2333, name="Cube", is_in_scene=False)
position = robot.getGripperGraspPointPosition()
cube.setTransform(position)

@app.route("/")
def hello_world():
    return "Hello world!"

@app.route('/joystick-direction/', methods=['POST'])
def handle_joystick_direction():
    data = request.json
    command = data.get('direction')
    command_queue.put(('direction', command))
    return jsonify({"message": "", "command": command})

@app.route('/grip-command/', methods=['POST'])
def handle_grip_command():
    data = request.json
    command = data.get('command')
    command_queue.put(('grip', command))
    return jsonify({"message": "Grip command received", "command": command})

@app.route('/arm-command/', methods=['POST'])
def handle_arm_command():
    data = request.json
    command = data.get('command')
    command_queue.put(('arm', command))
    return jsonify({"message": "Arm command received", "command": command})

@app.route('/get-positions/', methods=['GET'])
def get_positions():
    gripper_position = robot.getGripperGraspPointPosition()
    base_position = robot_base.getRobotState()["position"]
    return jsonify({
        "gripperPosition": gripper_position,
        "basePosition": base_position
    })

@app.route('/set-positions/', methods=['POST'])
def set_positions():
    print("load the set positions")
    data = request.get_json()
    gripper_position = data['gripperPosition']
    base_position = data['basePosition']
    command_queue.put(('set_positions', {'gripper': gripper_position, 'base': base_position}))
    return jsonify({"message": "Position setting command received"})


def move_forward():
    robot_base_position = robot_base.getRobotState()["position"]
    robot_base_position[0] += 0.008
    robot_base.setTransform(robot_base_position)
    env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())
def move_backward():
    robot_base_position = robot_base.getRobotState()["position"]
    robot_base_position[0] -= 0.008
    robot_base.setTransform(robot_base_position)
    env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())
def move_left():
    robot_base_position = robot_base.getRobotState()["position"]
    robot_base_position[2] += 0.008
    robot_base.setTransform(robot_base_position)
    env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())
def move_right():
    robot_base_position = robot_base.getRobotState()["position"]
    robot_base_position[2] -= 0.008
    robot_base.setTransform(robot_base_position)
    env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())

def grip():
    print("Gripping")
    robot.GripperClose()
    env.step()
def release():
    print("Releasing")
    robot.GripperOpen()
    env.step()

def lift_arm():
    for i in range(20):
        robot_arm_position = cube.getPosition()
        new_height = robot_arm_position[1] + 0.004
        cube.setTransform([cube.getPosition()[0], new_height, cube.getPosition()[2]])
        robot.BioIKMove(cube.getPosition())
        print("arm lifted")
        env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())

def drop_arm():
    for i in range(20):
        robot_arm_position = cube.getPosition()
        new_height = robot_arm_position[1] - 0.004
        cube.setTransform([cube.getPosition()[0], new_height, cube.getPosition()[2]])
        robot.BioIKMove(cube.getPosition())
        print("arm droped")
        # force on the sponge
        forces = env.instance_channel.data[509]["forces"]
        if forces:
            if forces[-1] > 200:
                new_height = robot_arm_position[1] + 0.006
                cube.setTransform([cube.getPosition()[0], new_height, cube.getPosition()[2]])
                robot.BioIKMove(cube.getPosition())
                env.step()
        env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())

def extend_arm():
    for i in range(20):
        robot_arm_position = cube.getPosition()
        new_length = robot_arm_position[2] + 0.004
        cube.setTransform([cube.getPosition()[0], cube.getPosition()[1], new_length])
        robot.BioIKMove(cube.getPosition())
        print("arm extended")
        env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())

def shrink_arm():
    for i in range(20):
        robot_arm_position = cube.getPosition()
        new_length = robot_arm_position[2] - 0.004
        cube.setTransform([cube.getPosition()[0], cube.getPosition()[1], new_length])
        robot.BioIKMove(cube.getPosition())
        print("arm shrinked")
        env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())

def reset_robot():
    for i in range(10):
        robot.reset()
        robot_base.reset()
        env.step()
    cube.setTransform(robot.getGripperGraspPointPosition())


def set_robot_positions(command):
    gripper_target = np.array(command['gripper'])
    base_target = np.array(command['base'])
    gripper_current = np.array(robot.getGripperGraspPointPosition())
    base_current = np.array(robot_base.getRobotState()["position"])
    steps = 20
    for i in range(1, steps + 1):
        gripper_step = gripper_current + (gripper_target - gripper_current) * (
                    i / steps)
        base_step = base_current + (base_target - base_current) * (i / steps)

        cube.setTransform(gripper_step.tolist())

        robot.BioIKMove(gripper_step.tolist())
        robot_base.setTransform(base_step.tolist())
        env.step()
        print(
            f"Step {i}: Moving to Gripper - {gripper_step}, Base - {base_step}")

    cube.setTransform(gripper_target.tolist())
    robot.BioIKMove(gripper_target.tolist())
    robot_base.BioIKMove(base_target.tolist())
    env.step()

    print(
        f"Final positions set: Gripper - {gripper_target}, Base - {base_target}")


def robot_control_loop():
    # global current_direction
    while True:
        prop = env.instance_channel.data[509]["proportion"]
        print("coverage: " + str(prop))
        
        if not command_queue.empty():
            command_type, command = command_queue.get()
            if command_type == 'direction':
                if command == "up":
                    move_forward()
                elif command == "down":
                    move_backward()
                elif command == "left":
                    move_left()
                elif command == "right":
                    move_right()
                else:
                    pass

            elif command_type == 'grip':
                if command == "catch":
                    grip()
                elif command == "release":
                    release()

            elif command_type == 'arm':
                if command == "lift":
                    lift_arm()
                elif command == "drop":
                    drop_arm()
                elif command == "extend":
                    extend_arm()
                elif command == "shrink":
                    shrink_arm()
                elif command == "resetrobot":
                    reset_robot()

            elif command_type == 'set_positions':
                print("position trace back")
                set_robot_positions(command)

        env.step()

# Script to test bed bathing in hackathon.
if __name__ == "__main__":
    # Open robot thread
    thread = Thread(target=robot_control_loop)
    thread.start()
    
    # Open Flask server
    app.run(host="0.0.0.0", port=8000, debug=True)
    
    