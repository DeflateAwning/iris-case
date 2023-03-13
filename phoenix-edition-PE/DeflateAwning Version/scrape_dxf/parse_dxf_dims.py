import pandas as pd

df = pd.read_json('dump.json')

holes_df = df[df['knots'] == 17]
print(f"Found {len(holes_df)} hole splines.")

outline = df[df['knots_count'] == 101].iloc[0].to_dict()
reset = df[df['knots_count'] == 29].iloc[0].to_dict() # reset box

w = outline['cp_x_max'] - outline['cp_x_min']
h = outline['cp_y_max'] - outline['cp_y_min']

cx = outline['cp_x_min'] + w/2
cy = outline['cp_y_min'] + h/2

prop = {'w': w, 'h': h, 'cx': cx, 'cy': cy}

print(f"Outline Properties: {prop}")

reset_w = reset['cp_x_max'] - reset['cp_x_min']
reset_h = reset['cp_y_max'] - reset['cp_y_min']

reset_cx = reset['cp_x_min'] + reset_w/2 - cx
reset_cy = reset['cp_y_min'] + reset_h/2 - cy

reset_y_circle_center = reset['cp_y_min'] + reset_w/2 - cy # add half the width, to the height

reset_prop = {'reset_w': reset_w, 'reset_h': reset_h, 'reset_cx': reset_cx, 'reset_cy': reset_cy, 'reset_y_circle_center': reset_y_circle_center}

print(f"Reset box: {reset_prop}")

#breakpoint()
...