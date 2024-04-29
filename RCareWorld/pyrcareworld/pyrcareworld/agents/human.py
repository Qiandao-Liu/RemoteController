from pyrcareworld.objects import RCareWorldBaseObject
from typing import Optional


class Human(RCareWorldBaseObject):
    """
    Humans in RCareWorld
    """

    def __init__(self, env, id: int, name: str, is_in_scene: bool = False):
        super().__init__(env=env, id=id, name=name, is_in_scene=is_in_scene)
        self.name_list = [
            "Pelvis",
            "Spine1",
            "Spine2",
            "Spine3",
            "LeftShoulder",
            "LeftUpperArm",
            "LeftLowerArm",
            "LeftHand",
            "RightShoulder",
            "RightUpperArm",
            "RightLowerArm",
            "RightHand",
            "LeftUpperLeg",
            "LeftLowerLeg",
            "LeftFoot",
            "LeftToes",
            "RightUpperLeg",
            "RightLowerLeg",
            "RightFoot",
            "RightToes",
            "Neck",
            "Head",
            "LeftEye",
            "RightEye",
            "Jaw",
            "LeftThumb1",
            "LeftThumb2",
            "LeftThumb3",
            "LeftIndex1",
            "LeftIndex2",
            "LeftIndex3",
            "LeftMiddle1",
            "LeftMiddle2",
            "LeftMiddle3",
            "LeftRing1",
            "LeftRing2",
            "LeftRing3",
            "LeftPinky1",
            "LeftPinky2",
            "LeftPinky3",
            "RightThumb1",
            "RightThumb2",
            "RightThumb3",
            "RightIndex1",
            "RightIndex2",
            "RightIndex3",
            "RightMiddle1",
            "RightMiddle2",
            "RightMiddle3",
            "RightRing1",
            "RightRing2",
            "RightRing3",
            "RightPinky1",
            "RightPinky2",
            "RightPinky3",
        ]

    def setBasePosition(self, position: list):
        self.env.instance_channel.set_action(
            "SetTransform", id=self.id, position=position
        )

    def setRootRotation(self, rotation: list):
        self.env.instance_channel.set_action(
            "SetTransform", id=self.id, rotation=rotation
        )

    def setJointRotationByName(self, joint_name: str, position: list):
        if joint_name not in self.name_list:
            raise ValueError("The joint name is not in the list")
        self.env.instance_channel.set_action(
            "SetNameBonePosition",
            id=self.id,
            bone_name=joint_name,
            bone_position=position[0],
            bone_position_y=position[1],
            bone_position_z=position[2],
        )

    def setJointLimits(
        self,
        joint_name: str,
        lower_limit: float,
        upper_limit: float,
        axis: Optional[str] = None,
    ):
        """
        Sets the joint limits for this human object in Unity.

        Args:
            joint_name: The name of the joint (or bone).
            lower_limit: The lower limit of the joint.
            upper_limit: The upper limit of the joint.
            axis: The axis of the joint. If None, all axes are set.
        """
        if joint_name not in self.name_list:
            raise ValueError("The joint name is not in the list")

        if (axis in ["X", "Y", "Z"]) is False:
            self.env.instance_channel.set_action(
                "SetJointLimits",
                id=self.id,
                bone_name=joint_name,
                lower_limit=lower_limit,
                upper_limit=upper_limit,
            )
        else:
            self.env.instance_channel.set_action(
                "SetJointLimits",
                id=self.id,
                bone_name=joint_name,
                lower_limit=lower_limit,
                upper_limit=upper_limit,
                axis=axis,
            )

    def setJointRotationByNameDirectly(self, joint_name: str, position: list):
        if joint_name not in self.name_list:
            raise ValueError("The joint name is not in the list")
        self.env.instance_channel.set_action(
            "SetNameBonePositionDirectly",
            id=self.id,
            bone_name=joint_name,
            bone_position=position[0],
            bone_position_y=position[1],
            bone_position_z=position[2],
        )

    def getJointStateByName(self, joint_name: str):
        if joint_name not in self.name_list:
            raise ValueError("The joint name is not in the list")
        # print(self.env.instance_channel.data)
        joint_states = self.env.instance_channel.data[self.id][joint_name]
        return joint_states

    def getJointPositionByName(self, joint_name: str):
        """
        Position in the world coordinate
        """
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["position"]

    def getJointGlobalRotationByName(self, joint_name: str):
        """
        Euler angles in degrees
        """
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["rotation"]

    def getJointQuaternionByName(self, joint_name: str):
        """
        Quaternion
        """
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["quaternion"]

    def getJointLocalRotationByName(self, joint_name: str):
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["local_rotation"]

    def getJointLocalQuaternionByName(self, joint_name: str):
        """
        Quaternion
        """
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["local_quaternion"]

    def getJointVelocityByName(self, joint_name: str):
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["velocity"]

    def getJointRotationByName(self, joint_name: str):
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["joint_position"]

    def getJointAccelerationByName(self, joint_name: str):
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["acceleration"]

    def getJointForceByName(self, joint_name: str):
        joint_states = self.getJointStateByName(joint_name)
        return joint_states["joint_force"]

    def saveArticulationBoneData(self, path: str):
        self.env.instance_channel.set_action(
            "SaveArticulationBoneData", id=self.id, path=path
        )

    def enableSoftBody(self):
        """
        TODO: enable soft body
        """
        self.env.instance_channel.set_action("EnableSoftBody", id=self.id)