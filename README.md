# Second-Order-Dynamics
Second Order Dynamics Addon for Godot ⚙️🎮  A Godot addon that implements Second Order Dynamics for smoother, more natural, and customizable motion. Ideal for spring-like movement, responsive animations, and physics-based effects with precise control over damping, frequency, and responsiveness. 🚀

# ✨ Features:

✔️ **Fully Customizable Motion Response** – Easily tweak parameters to fine-tune system dynamics and achieve the desired motion behavior.

✔️ **System Gain** (k) – Controls the overall amplitude of the response by scaling the output proportionally.

✔️ **Natural Frequency** (𝜔0 - (wo in editor)) – Defines the inherent oscillation speed of the system, affecting how fast it reacts to changes.

✔️ **Damping Ratio** (𝜉 - (xi in editor) – Adjusts how quickly oscillations decay, allowing for underdamped, critically damped, or overdamped responses.

✔️ **Velocity Coupling Factor** (z) – Modifies the influence of input velocity on the output, enabling reverse or stronger starts .

✔️ **Optimized for Performance** – Efficient calculations ensure smooth runtime behavior.

✔️ **Real-Time Visual Feedback** – A built-in line chart in the inspector provides instant visualization of the system's response.

✔️ **Seamless Integration** – Designed for Godot 4.3, the charts adapts to your theme and window size.

✔️ **Example Scene** – Project include a simple example scene.

# 📦 Installation:

1. **Download the Addon:** Clone or download the repository from GitHub.
2. **Move the Folder:** Place the verlet_rope_addon folder inside your "res://addons/" directory.
3. **Enable the Plugin:**

    Open Godot Editor.
   
    Go to Project > Project Settings > Plugins.
   
    Enable SecondOrderDynamics Addon.

**Note:** You only need to place the SecondOrderDynamics folder in "res://addons/" in your godot app.

# 🛠️ Usage Guide:

## Implementing the plugin for a node:

To use the plugin you need to add two export variables, one of type SecondOrderSystem (from the addon) and one  dictionnary (which is used for the parameters).
The plugin can detect the config dictionnary and associate it with the SecondOrderSystem on conditions:
  1. The dictionnary must be placed above the SecondOrderSystem.
  2. The part of the variable names before the first underscore (let's call it name_id) must match exactly for proper configuration.
  3. If you use multiple SecondOrderSystems for one node, the name id must be unique per SecondOrderSystem.

### Correct implementation:

      @export var name_config_dictionnary : Dictionnary
      @export var name_second_order : SecondOrderSystem

### Incorrect implementation:

Name_ids not unique

      @export var second_config_dictionnary : Dictionnary
      @export var second_order : SecondOrderSystem

      @export var second_config_dictionnary : Dictionnary
      @export var second_order : SecondOrderSystem

Different name_ids

      @export var config_dictionnary : Dictionnary
      @export var second_order : SecondOrderSystem

Finnally you need to initiate your SecondOrderSystem in the ready function for it to work in game.

      func _ready() -> void:
        name_second_order = SecondOrderSystem.new(second_config_dictionnary)

With theses 4 lines of code your SecondOrderSystem should be all setup, the line chart should have appeared in the inspector node.

## Using the plugin in game:

To customize your movement response with the plugin, you need to call the function respective functions for vector2 and vector3:

      	output_velocity = move_second_order.vec2_second_order_response(delta,input_velocity,output_velocity,)["output"]
        output_velocity = move_second_order.vec3_second_order_response(delta,input_velocity,output_velocity,)["output"]

**Note:** 

You can use the plugin on position,speed or acceleration, but also on rotation, rotation_speed...
I find it has best result on speed but have a try and find out what suit your needs the best.


## 📝 License:

This project is licensed under the CC BY-NC 4.0, you can use and modify it except for commercial uses credit is needed. 

## 🌟 Support:

❓ Need help? feel free to ask i will gladly help.





