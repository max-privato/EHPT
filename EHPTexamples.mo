package EHPTexamples "Package containing basic EV models"
  package ElectricDrives
    model tqFollowing "Compares U/f=cost and mains start-ups"
      //
      import Modelica.Constants.pi;
      extends Modelica.Icons.Example;
      Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox annotation (
        Placement(visible = true, transformation(extent = {{4, 14}, {24, 34}}, rotation = 0)));
      Modelica.Electrical.Machines.BasicMachines.InductionMachines.IM_SquirrelCage
        aimc(alpha20s=0, alpha20r=0)
             annotation (Placement(visible=true, transformation(extent={{4,-16},
                {24,4}}, rotation=0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(extent = {{-98, -36}, {-78, -16}}, rotation = 0)));
      Modelica.Electrical.Polyphase.Basic.Star star annotation (Placement(
            visible=true, transformation(
            origin={-88,8},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      EHPTlib.SupportModels.Miscellaneous.AronSensor pUp annotation (
        Placement(visible = true, transformation(extent = {{-38, 14}, {-20, 32}}, rotation = 0)));
      Modelica.Electrical.Polyphase.Sources.SignalVoltage signalV annotation (
          Placement(visible=true, transformation(
            origin={-58,23},
            extent={{-10,-9},{10,9}},
            rotation=180)));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(visible = true, transformation(origin = {61, -25}, extent = {{-7, -7}, {7, 7}}, rotation = 270)));
      Modelica.Electrical.Polyphase.Sensors.CurrentSensor iUp annotation (
          Placement(visible=true, transformation(
            origin={-6,40},
            extent={{-8,-8},{8,8}},
            rotation=0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5) annotation (
        Placement(visible = true, transformation(extent = {{34, -16}, {54, 4}}, rotation = 0)));
      EHPTlib.ElectricDrives.ASMArelated.ControlLogic logic(Rr = aimc.Rr, Rs = aimc.Rs, wmMax = 314.16 / 2, uBase = 100 * sqrt(3), Lstray = aimc.Lssigma + aimc.Lrsigma, pp = aimc.p) annotation (
        Placement(visible = true, transformation(extent = {{-18, -54}, {-38, -34}}, rotation = 0)));
      EHPTlib.ElectricDrives.ASMArelated.GenSines genSines annotation (
        Placement(visible = true, transformation(origin = {-59, -6}, extent = {{11, -10}, {-11, 10}}, rotation = -90)));
      Modelica.Blocks.Sources.Trapezoid tqReq(amplitude = 150, falling = 2, offset = 50, period = 100, rising = 2, startTime = 2, width = 3) annotation (
        Placement(visible = true, transformation(origin = {10, -44}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque tqRes(tau_nominal = -150, w_nominal = 157.08) annotation (
        Placement(visible = true, transformation(origin = {90, -6}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
    equation
      connect(speedSensor.flange, inertia.flange_b) annotation (
        Line(points = {{61, -18}, {60, -18}, {60, -6}, {54, -6}, {54, -6}}));
      connect(inertia.flange_b, tqRes.flange) annotation (
        Line(points = {{54, -6}, {80, -6}}));
      connect(logic.Tstar, tqReq.y) annotation (
        Line(points={{-16.1,-44.1},{-10,-44.1},{-10,-44},{-1,-44}},          color = {0, 0, 127}));
      connect(genSines.Westar, logic.Westar) annotation (
        Line(points = {{-53.1, -18.43}, {-54.1, -18.43}, {-54.1, -36.43}, {-52.6, -36.43}, {-52.6, -38}, {-39, -38}}, color = {0, 0, 127}));
      connect(genSines.U, signalV.v) annotation (
        Line(points={{-59,6.1},{-58,6.1},{-58,12.2}},        color = {0, 0, 127}));
      connect(genSines.Ustar, logic.Ustar) annotation (
        Line(points = {{-64.9, -18.43}, {-63.9, -18.43}, {-63.9, -50}, {-39, -50}}, color = {0, 0, 127}));
      connect(terminalBox.plug_sn, aimc.plug_sn) annotation (
        Line(points = {{8, 18}, {8, 4}}, color = {0, 0, 255}));
      connect(terminalBox.plug_sp, aimc.plug_sp) annotation (
        Line(points = {{20, 18}, {20, 4}}, color = {0, 0, 255}));
      connect(iUp.plug_n, terminalBox.plugSupply) annotation (
        Line(points = {{2, 40}, {14, 40}, {14, 20}}, color = {0, 0, 255}));
      connect(inertia.flange_a, aimc.flange) annotation (
        Line(points = {{34, -6}, {24, -6}}));
      connect(ground.p, star.pin_n) annotation (
        Line(points = {{-88, -16}, {-88, -2}}, color = {0, 0, 255}));
      connect(signalV.plug_n, star.plug_p) annotation (
        Line(points = {{-68, 23}, {-88, 23}, {-88, 18}}, color = {0, 0, 255}));
      connect(pUp.pc, signalV.plug_p) annotation (
        Line(points = {{-38, 23}, {-42, 23}, {-42, 24}, {-44, 24}, {-44, 23}, {-48, 23}}, color = {0, 0, 255}));
      connect(iUp.plug_p, pUp.nc) annotation (
        Line(points = {{-14, 40}, {-20, 40}, {-20, 23}}, color = {0, 0, 255}));
      connect(logic.Wm, speedSensor.w) annotation (
        Line(points = {{-28.1, -55.3}, {-28.1, -62.3}, {61, -62.3}, {61, -32.7}}, color = {0, 0, 127}));
      annotation (
        experimentSetupOutput,
        Documentation(info = "<html><head></head><body><p><font size=\"5\">This system simulates variable-frequency start-up of an asyncronous motor.</font></p>
<p><font size=\"5\">Two different sources for the machine are compared.</font></p>
<p><font size=\"5\">The motor supply is constituted by a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</font></p>
<p><font size=\"5\">WEl=WMecc*PolePairs+DeltaWEl</font></p>
<p><font size=\"5\">U=U0+(Un-U0)*WEl/WNom</font></p>
<p><font size=\"5\">where:</font></p>
<p></p><ul>
<li><font size=\"5\">U0, Un U, are initial, nominal actual voltage amplitudes</font></li>
<li><font size=\"5\">WMecc, WEl, are machine, mechanical and supply, electrical angular speeds</font></li>
<li><font size=\"5\">PolePairs are the machine pole pairs</font></li>
<li><font size=\"5\">delta WEl is a fixed parameter during the simulation, except when the final speed is reached</font></li>
</ul><p></p>
<p><font size=\"5\">When the final speed is reached, the feeding frequency and voltage are kept constant (no flux weaking simulated)</font></p>
</body></html>"),
        experimentSetupOutput,
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -80}, {100, 60}})),
        Diagram(coordinateSystem(extent = {{-100, -80}, {100, 60}}, preserveAspectRatio = false), graphics={  Rectangle(origin = {-57, 26}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-15, 10}, {15, -48}}), Text(origin = {-30, -1}, extent = {{-8, 3}, {8, -3}}, textString = "inverter")}),
        experiment(StartTime = 0, StopTime = 12, Tolerance = 0.0001, Interval = 0.0024),
        __OpenModelica_commandLineOptions = "");
    end tqFollowing;

    model wFollowing "Compares U/f=cost and mains start-ups"
      //
      import Modelica.Constants.pi;
      extends Modelica.Icons.Example;
      Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox annotation (
        Placement(visible = true, transformation(extent = {{4, 14}, {24, 34}}, rotation = 0)));
      Modelica.Electrical.Machines.BasicMachines.InductionMachines.IM_SquirrelCage
        aimc annotation (Placement(visible=true, transformation(extent={{4,-16},
                {24,4}}, rotation=0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(extent = {{-98, -36}, {-78, -16}}, rotation = 0)));
      Modelica.Electrical.Polyphase.Basic.Star star annotation (Placement(
            visible=true, transformation(
            origin={-88,8},
            extent={{-10,-10},{10,10}},
            rotation=270)));
      EHPTlib.SupportModels.Miscellaneous.AronSensor pUp annotation (
        Placement(visible = true, transformation(extent = {{-38, 14}, {-20, 32}}, rotation = 0)));
      Modelica.Electrical.Polyphase.Sources.SignalVoltage signalV annotation (
          Placement(visible=true, transformation(
            origin={-58,23},
            extent={{-10,-9},{10,9}},
            rotation=180)));
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(visible = true, transformation(origin = {75, -27}, extent = {{-7, -7}, {7, 7}}, rotation = 270)));
      Modelica.Electrical.Polyphase.Sensors.CurrentSensor iUp annotation (
          Placement(visible=true, transformation(
            origin={-6,40},
            extent={{-8,-8},{8,8}},
            rotation=0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5) annotation (
        Placement(visible = true, transformation(extent = {{34, -16}, {54, 4}}, rotation = 0)));
      EHPTlib.ElectricDrives.ASMArelated.ControlLogic logic(Rr = aimc.Rr, Rs = aimc.Rs,  wmMax = 314.16 / 2, uBase = 100 * sqrt(3), Lstray = aimc.Lssigma + aimc.Lrsigma, pp = aimc.p) annotation (
        Placement(visible = true, transformation(extent = {{-28, -54}, {-48, -34}}, rotation = 0)));
      EHPTlib.ElectricDrives.ASMArelated.GenSines genSines annotation (
        Placement(visible = true, transformation(origin = {-59, -6}, extent = {{11, -10}, {-11, 10}}, rotation = -90)));
      Modelica.Blocks.Sources.Trapezoid wReq(amplitude = 1000, falling = 2, offset = 0, period = 100, rising = 2, startTime = 2, width = 3) annotation (
        Placement(visible = true, transformation(origin = {59, -41}, extent = {{7, -7}, {-7, 7}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque tqRes(tau_nominal = -150, w_nominal = 157.08) annotation (
        Placement(visible = true, transformation(origin = {100, -6}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      Modelica.Blocks.Math.UnitConversions.From_rpm fromRpm annotation (
        Placement(visible = true, transformation(origin = {35, -41}, extent = {{7, -7}, {-7, 7}}, rotation = 0)));
      Modelica.Blocks.Math.Feedback fb annotation (
        Placement(visible = true, transformation(origin = {10, -40}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      Modelica.Blocks.Math.Gain gain(k = 20) annotation (
        Placement(visible = true, transformation(origin = {-13, -41}, extent = {{7, -7}, {-7, 7}}, rotation = 0)));
    equation
      connect(gain.u, fb.y) annotation (
        Line(points = {{-4.6, -41}, {1, -41}, {1, -40}}, color = {0, 0, 127}));
      connect(gain.y, logic.Tstar) annotation (
        Line(points={{-20.7,-41},{-26.1,-41},{-26.1,-44.1}},        color = {0, 0, 127}));
      connect(fb.u1, fromRpm.y) annotation (
        Line(points = {{18, -40}, {28, -40}, {28, -40}, {28, -41}, {27.3, -41}}, color = {0, 0, 127}));
      connect(fb.u2, speedSensor.w) annotation (
        Line(points = {{10, -48}, {10, -54}, {80, -54}, {80, -34.7}, {75, -34.7}}, color = {0, 0, 127}));
      connect(fromRpm.u, wReq.y) annotation (
        Line(points = {{43.4, -41}, {51.3, -41}}, color = {0, 0, 127}));
      connect(logic.Wm, speedSensor.w) annotation (
        Line(points = {{-38.1, -55.3}, {-38.1, -64.3}, {75, -64.3}, {75, -34.7}}, color = {0, 0, 127}));
      connect(genSines.Ustar, logic.Ustar) annotation (
        Line(points = {{-64.9, -18.43}, {-63.9, -18.43}, {-63.9, -50}, {-49, -50}}, color = {0, 0, 127}));
      connect(genSines.Westar, logic.Westar) annotation (
        Line(points = {{-53.1, -18.43}, {-54.1, -18.43}, {-54.1, -36.43}, {-52.6, -36.43}, {-52.6, -38}, {-49, -38}}, color = {0, 0, 127}));
      connect(inertia.flange_b, tqRes.flange) annotation (
        Line(points = {{54, -6}, {90, -6}}));
      connect(speedSensor.flange, inertia.flange_b) annotation (
        Line(points = {{75, -20}, {74.5, -20}, {74.5, -8}, {74, -8}, {74, -6}, {54, -6}}));
      connect(genSines.U, signalV.v) annotation (
        Line(points={{-59,6.1},{-58,6.1},{-58,12.2}},        color = {0, 0, 127}));
      connect(terminalBox.plug_sn, aimc.plug_sn) annotation (
        Line(points = {{8, 18}, {8, 4}}, color = {0, 0, 255}));
      connect(terminalBox.plug_sp, aimc.plug_sp) annotation (
        Line(points = {{20, 18}, {20, 4}}, color = {0, 0, 255}));
      connect(iUp.plug_n, terminalBox.plugSupply) annotation (
        Line(points = {{2, 40}, {14, 40}, {14, 20}}, color = {0, 0, 255}));
      connect(inertia.flange_a, aimc.flange) annotation (
        Line(points = {{34, -6}, {24, -6}}));
      connect(ground.p, star.pin_n) annotation (
        Line(points = {{-88, -16}, {-88, -2}}, color = {0, 0, 255}));
      connect(signalV.plug_n, star.plug_p) annotation (
        Line(points = {{-68, 23}, {-88, 23}, {-88, 18}}, color = {0, 0, 255}));
      connect(pUp.pc, signalV.plug_p) annotation (
        Line(points = {{-38, 23}, {-42, 23}, {-42, 24}, {-44, 24}, {-44, 23}, {-48, 23}}, color = {0, 0, 255}));
      connect(iUp.plug_p, pUp.nc) annotation (
        Line(points = {{-14, 40}, {-20, 40}, {-20, 23}}, color = {0, 0, 255}));
      annotation (
        experimentSetupOutput,
        Documentation(info = "<html>
<p>This system simulates variable-frequency start-up of an asyncronous motor.</p>
<p>Two different sources for the machine re compared.</p>
<p>The motor supply is constituted by a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</p>
<p>WEl=WMecc*PolePairs+DeltaWEl</p>
<p>U=U0+(Un-U0)*WEl/WNom</p>
<p>where:</p>
<p><ul>
<li>U0, Un U, are initial, nominal actual voltage amplitudes</li>
<li>WMecc, WEl, are machine, mechanical and supply, electrical angular speeds</li>
<li>PolePairs are the machine pole pairs</li>
<li>delta WEl is a fixed parameter during the simulation, except when the final speed is reached</li>
</ul></p>
<p>When the final speed is reached, the feeding frequenccy and voltage are kept constant (no flux weaking simulated)</p>
</html>"),
        experimentSetupOutput,
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}})),
        Diagram(coordinateSystem(extent = {{-100, -80}, {120, 60}}, preserveAspectRatio = false), graphics={  Rectangle(origin = {-57, 26}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-15, 10}, {15, -48}}), Text(origin = {-30, -1}, extent = {{-8, 3}, {8, -3}}, textString = "inverter")}),
        experiment(StartTime = 0, StopTime = 12, Tolerance = 0.0001, Interval = 0.0024),
        __OpenModelica_commandLineOptions = "");
    end wFollowing;
  end ElectricDrives;

  package EV
    model FirstEV "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      EHPTlib.SupportModels.Miscellaneous.DragForce dragF(Cx = 0.26, S = 2.2, fc = 0.014, m = mass.m, rho(displayUnit = "kg/m3") = 1.226) annotation (
        Placement(visible = true, transformation(origin = {82, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 4) annotation (
        Placement(visible = true, transformation(origin = {-14, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
        Placement(visible = true, transformation(extent = {{-82, 10}, {-62, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 1000, yMax = 100000.0) annotation (
        Placement(visible = true, transformation(extent = {{-118, 14}, {-98, 34}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{34, 10}, {54, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {60, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(extent = {{4, 10}, {24, 30}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 1.5) annotation (
        Placement(visible = true, transformation(extent = {{-54, 10}, {-34, 30}}, rotation = 0)));
    equation
      connect(torque.tau, driver.tauRef) annotation (
        Line(points = {{-84, 20}, {-90.5, 20}, {-90.5, 24}, {-97, 24}}, color = {0, 0, 127}));
      connect(driver.V, velSens.v) annotation (
        Line(points={{-108,12.8},{-108,-36},{60,-36},{60,-21}},        color = {0, 0, 127}));
      connect(mass.flange_b, dragF.flange) annotation (
        Line(points = {{54, 20}, {82, 20}, {82, -16}}, color = {0, 127, 0}));
      connect(velSens.flange, mass.flange_b) annotation (
        Line(points = {{60, 0}, {60, 20}, {54, 20}}, color = {0, 127, 0}));
      connect(mass.flange_a, wheel.flangeT) annotation (
        Line(points = {{34, 20}, {24, 20}}, color = {0, 127, 0}));
      connect(inertia.flange_a, torque.flange) annotation (
        Line(points = {{-54, 20}, {-58, 20}, {-62, 20}}));
      connect(inertia.flange_b, gear.flange_a) annotation (
        Line(points = {{-34, 20}, {-24, 20}}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-4, 20}, {-4, 20}, {4, 20}}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>Very basic introductory EV model</p>
</html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -40}, {100, 40}}, preserveAspectRatio = false), graphics={  Rectangle(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-84, 36}, {-24, 4}}), Text(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-82, 2}, {-26, -4}}, textString = "electric drive")}),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 200, Tolerance = 0.0001, Interval = 0.1),
        __OpenModelica_simulationFlags(jacobian = "", s = "dassl", lv = "LOG_STATS"),
        __OpenModelica_commandLineOptions = "");
    end FirstEV;

    model EVdata "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      EHPTlib.SupportModels.Miscellaneous.DragForce dragF(m = mass.m, rho(displayUnit = "kg/m3") = data.rho, S = data.S, fc = data.fc, Cx = data.Cx) annotation (
        Placement(visible = true, transformation(origin = {82, -26}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = data.ratio) annotation (
        Placement(visible = true, transformation(origin = {-14, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
        Placement(visible = true, transformation(extent = {{-82, 10}, {-62, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, yMax = 100000.0, k = data.kContr) annotation (
        Placement(visible = true, transformation(extent = {{-118, 10}, {-98, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = data.m) annotation (
        Placement(visible = true, transformation(extent = {{34, 10}, {54, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {60, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = data.radius) annotation (
        Placement(visible = true, transformation(extent = {{4, 10}, {24, 30}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = data.J) annotation (
        Placement(visible = true, transformation(extent = {{-54, 10}, {-34, 30}}, rotation = 0)));
      VehicleData.Car data annotation (
        Placement(transformation(extent = {{30, 40}, {50, 60}})));
    equation
      connect(mass.flange_b, dragF.flange) annotation (
        Line(points = {{54, 20}, {82, 20}, {82, -16}}, color = {0, 127, 0}));
      connect(velSens.flange, mass.flange_b) annotation (
        Line(points = {{60, 0}, {60, 20}, {54, 20}}, color = {0, 127, 0}));
      connect(driver.V, velSens.v) annotation (
        Line(points = {{-108, 8.8}, {-108, -36}, {60, -36}, {60, -21}}, color = {0, 0, 127}));
      connect(mass.flange_a, wheel.flangeT) annotation (
        Line(points = {{34, 20}, {24, 20}}, color = {0, 127, 0}));
      connect(inertia.flange_a, torque.flange) annotation (
        Line(points = {{-54, 20}, {-58, 20}, {-62, 20}}));
      connect(inertia.flange_b, gear.flange_a) annotation (
        Line(points = {{-34, 20}, {-24, 20}}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-4, 20}, {-4, 20}, {4, 20}}));
      connect(torque.tau, driver.tauRef) annotation (
        Line(points = {{-84, 20}, {-97, 20}}, color = {0, 0, 127}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html><head></head><body><p>Very basic introductory EV model, but with use of \"data\" record for car's parameters.</p>
</body></html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -40}, {100, 60}}, preserveAspectRatio = false), graphics = {Rectangle(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-84, 36}, {-24, 4}}), Text(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-82, 2}, {-26, -4}}, textString = "electric drive")}),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 200, Tolerance = 0.0001, Interval = 0.1),
        __OpenModelica_simulationFlags(jacobian = "", s = "dassl", lv = "LOG_STATS"),
        __OpenModelica_commandLineOptions = "");
    end EVdata;

    model FirstEVpow "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      EHPTlib.SupportModels.Miscellaneous.DragForce dragF(Cx = 0.26, S = 2.2, fc = 0.014, m = mass.m, rho(displayUnit = "kg/m3") = 1.226) annotation (
        Placement(visible = true, transformation(origin = {100, -22}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 4) annotation (
        Placement(visible = true, transformation(origin = {-8, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
        Placement(visible = true, transformation(extent = {{-76, 10}, {-56, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "Sort1.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 1000, yMax = 100000.0) annotation (
        Placement(visible = true, transformation(extent = {{-112, 8}, {-92, 28}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{54, 10}, {74, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {78, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(extent = {{10, 10}, {30, 30}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 1.5) annotation (
        Placement(visible = true, transformation(extent = {{-48, 10}, {-28, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP2 annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {100, 6})));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP1 annotation (
        Placement(transformation(extent = {{36, 12}, {52, 28}})));
    equation
      connect(torque.tau, driver.tauRef) annotation (
        Line(points = {{-78, 20}, {-91, 20}}, color = {0, 0, 127}));
      connect(driver.V, velSens.v) annotation (
        Line(points = {{-102, 8.8}, {-102, -36}, {78, -36}, {78, -21}}, color = {0, 0, 127}));
      connect(inertia.flange_b, gear.flange_a) annotation (
        Line(points = {{-28, 20}, {-18, 20}}));
      connect(inertia.flange_a, torque.flange) annotation (
        Line(points = {{-48, 20}, {-52, 20}, {-56, 20}}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{2, 20}, {2, 20}, {10, 20}}));
      connect(velSens.flange, mass.flange_b) annotation (
        Line(points = {{78, 4.44089e-016}, {78, 20}, {74, 20}}, color = {0, 127, 0}));
      connect(pP2.flange_b, dragF.flange) annotation (
        Line(points = {{100, -4}, {100, -12}}, color = {0, 127, 0}));
      connect(pP2.flange_a, mass.flange_b) annotation (
        Line(points = {{100, 16}, {100, 20}, {74, 20}}, color = {0, 127, 0}));
      connect(mass.flange_a, pP1.flange_b) annotation (
        Line(points = {{54, 20}, {54, 20}, {52, 20}}, color = {0, 127, 0}));
      connect(wheel.flangeT, pP1.flange_a) annotation (
        Line(points = {{30, 20}, {34, 20}, {36, 20}}, color = {0, 127, 0}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>Very basic introductory EV model with power measurements.</p>
</html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -40}, {120, 40}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-84, 36}, {-24, 4}}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash), Text(extent = {{-82, 2}, {-26, -4}}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, textString = "electric drive")}),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 200, Tolerance = 0.0001, Interval = 0.1),
        __OpenModelica_simulationFlags(jacobian = "", s = "dassl", lv = "LOG_STATS"));
    end FirstEVpow;

    model MBEVdata "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      Modelica.Units.SI.Energy enBatDel;
      Modelica.Units.SI.Energy enDTdel;
      Modelica.Units.SI.Energy enP1del;
      Modelica.Units.SI.Energy enBattLoss;
      Modelica.Units.SI.Energy enBraking;
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = data.ratio) annotation (
        Placement(visible = true, transformation(origin = {-20, 14}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = data.kContr, yMax = 100000.0) annotation (
        Placement(visible = true, transformation(extent = {{-116, -10}, {-96, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.5715) annotation (
        Placement(visible = true, transformation(extent = {{-4, 4}, {16, 24}}, rotation = 0)));
      EHPTlib.MapBased.OneFlange eleDrive(J = data.J, effTableName = "effTable", mapsFileName = "EVmaps.txt", mapsOnFile = true, powMax = 22e3, tauMax = 200, wMax = 1000) "Electric Drive" annotation (
        Placement(visible = true, transformation(extent = {{-74, 6}, {-54, 24}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.Batt1 batt1(SOCInit = 0.7, QCellNom = 100 * 3600, ns = 100) annotation (
        Placement(transformation(extent = {{-112, 34}, {-92, 54}})));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(extent = {{-84, -20}, {-64, 0}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP1 annotation (
        Placement(visible = true, transformation(origin = {32, 14}, extent = {{-6, -8}, {6, 8}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = data.m) annotation (
        Placement(visible = true, transformation(extent = {{56, 4}, {76, 24}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP2 annotation (
        Placement(visible = true, transformation(origin = {98, 4}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {68, -42}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragF(Cx = data.Cx, S = data.S, fc = data.fc, m = data.m, rho = data.rho) annotation (
        Placement(visible = true, transformation(origin = {98, -24}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Translational.Sources.Force brake annotation (
        Placement(visible = true, transformation(origin = {32, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sensors.TorqueSensor edTau annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 0, origin = {-42, 14})));
      Modelica.Blocks.Math.Add add(k1 = -1) annotation (
        Placement(transformation(extent = {{-42, -26}, {-30, -14}})));
      Modelica.Blocks.Math.Gain tqToForce(k = gear.ratio * wheel.radius) annotation (
        Placement(visible = true, transformation(extent = {{0, -26}, {12, -14}}, rotation = 0)));
      Modelica.Blocks.Nonlinear.Limiter cutNeg(uMax=0, uMin=-Modelica.Constants.inf)
        annotation (Placement(visible=true, transformation(
            origin={-14,-20},
            extent={{-6,-6},{6,6}},
            rotation=0)));
      VehicleData.Car data annotation (
        Placement(visible = true, transformation(origin = {70, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(batt1.n, eleDrive.pin_n) annotation (
        Line(points = {{-91.9, 38}, {-80, 38}, {-80, 10}, {-74, 10}}, color = {0, 0, 255}));
      connect(eleDrive.pin_n, ground.p) annotation (
        Line(points = {{-74, 10}, {-74, 10}, {-74, 0}, {-74, 0}}, color = {0, 0, 255}));
      connect(eleDrive.tauRef, driver.tauRef) annotation (
        Line(points = {{-75.4, 14}, {-86, 14}, {-86, 0}, {-95, 0}}, color = {0, 0, 127}));
      connect(batt1.p, eleDrive.pin_p) annotation (
        Line(points = {{-92, 50}, {-74, 50}, {-74, 18}}, color = {0, 0, 255}));
      connect(edTau.flange_a, eleDrive.flange_a) annotation (
        Line(points = {{-50, 14}, {-54, 14}}));
      connect(tqToForce.y, brake.f) annotation (
        Line(points = {{12.6, -20}, {18, -20}, {18, -20}, {20, -20}}, color = {0, 0, 127}));
      connect(cutNeg.y, tqToForce.u) annotation (
        Line(points = {{-7.4, -20}, {-2, -20}, {-2, -20}, {-1.2, -20}}, color = {0, 0, 127}));
      connect(cutNeg.u, add.y) annotation (
        Line(points = {{-21.2, -20}, {-30, -20}, {-30, -20}, {-29.4, -20}}, color = {0, 0, 127}));
      connect(brake.flange, pP1.flange_b) annotation (
        Line(points = {{42, -20}, {46, -20}, {46, 14}, {38, 14}}, color = {0, 127, 0}));
      connect(velSens.flange, pP2.flange_a) annotation (
        Line(points = {{78, -42}, {78, 14}, {98, 14}}, color = {0, 127, 0}));
      connect(driver.V, velSens.v) annotation (
        Line(points = {{-106, -11.2}, {-106, -42}, {57, -42}}, color = {0, 0, 127}));
      connect(mass.flange_a, pP1.flange_b) annotation (
        Line(points = {{56, 14}, {38, 14}}, color = {0, 127, 0}));
      connect(pP2.flange_a, mass.flange_b) annotation (
        Line(points = {{98, 14}, {76, 14}}, color = {0, 127, 0}));
      connect(pP1.flange_a, wheel.flangeT) annotation (
        Line(points = {{26, 14}, {16, 14}}, color = {0, 127, 0}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-10, 14}, {-4, 14}}));
      connect(dragF.flange, pP2.flange_b) annotation (
        Line(points = {{98, -14}, {98, -6}}, color = {0, 127, 0}));
      der(enBatDel) = (batt1.p.v - batt1.n.v) * batt1.n.i;
      der(enDTdel) = eleDrive.powSensor.power;
      der(enP1del) = pP1.power;
      der(enBattLoss) = batt1.powerLoss;
      der(enBraking) = if pP1.power > 0 then 0 else -pP1.power;
      connect(add.u2, driver.tauRef) annotation (
        Line(points = {{-43.2, -23.6}, {-86, -23.6}, {-86, 0}, {-95, 0}}, color = {0, 0, 127}));
      connect(edTau.flange_b, gear.flange_a) annotation (
        Line(points = {{-34, 14}, {-30, 14}, {-30, 14}}, color = {0, 0, 0}));
      connect(add.u1, edTau.tau) annotation (
        Line(points = {{-43.2, -16.4}, {-48.4, -16.4}, {-48.4, 5.2}}, color = {0, 0, 127}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>Simple map-based EV model with battery.</p>
</html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -60}, {120, 60}}, preserveAspectRatio = false)),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 0.1),
        __OpenModelica_commandLineOptions = "");
    end MBEVdata;

    model FirstEVAngle "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 6) annotation (
        Placement(visible = true, transformation(origin = {-14, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
        Placement(visible = true, transformation(extent = {{-82, 10}, {-62, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 1000, yMax = 100000.0, CycleFileName = "TestAngle.txt") annotation (
        Placement(visible = true, transformation(extent = {{-118, 10}, {-98, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{34, 10}, {54, 30}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {60, -10}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.5715) annotation (
        Placement(visible = true, transformation(extent = {{4, 10}, {24, 30}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 5) annotation (
        Placement(visible = true, transformation(extent = {{-54, 10}, {-34, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.DragForceAngle dragF(Cx = 0.65, S = 6.0, fc = 0.013, m = mass.m, rho = 1.226, DataFileName = "Angle1.txt") annotation (
        Placement(visible = true, transformation(origin = {82, -24}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    equation
      connect(velSens.flange, mass.flange_b) annotation (
        Line(points = {{60, 0}, {60, 20}, {54, 20}}, color = {0, 127, 0}));
      connect(driver.V, velSens.v) annotation (
        Line(points = {{-108, 8.8}, {-108, -36}, {60, -36}, {60, -21}}, color = {0, 0, 127}));
      connect(mass.flange_a, wheel.flangeT) annotation (
        Line(points = {{34, 20}, {24, 20}}, color = {0, 127, 0}));
      connect(inertia.flange_a, torque.flange) annotation (
        Line(points = {{-54, 20}, {-58, 20}, {-62, 20}}));
      connect(inertia.flange_b, gear.flange_a) annotation (
        Line(points = {{-34, 20}, {-24, 20}}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-4, 20}, {-4, 20}, {4, 20}}));
      connect(torque.tau, driver.tauRef) annotation (
        Line(points = {{-84, 20}, {-97, 20}}, color = {0, 0, 127}));
      connect(dragF.flange, mass.flange_b) annotation (
        Line(points = {{82, -14}, {82, 20}, {54, 20}}, color = {0, 127, 0}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html><head></head><body><p>Basic EV model with resistance to movement which includes slope.</p><p>Note that the model is only partially working since it is not able to stop the vehicle with negative angles when zero speed is needed.&nbsp;</p><p>Check the variable dragF.locked when the driver cycle is Sort1.txt: for t=80-100s the requested speed is zero, but the variable dragF.locked remains false.</p><p>Fixing this requires implementing a totally different driver's model, since the driver in these cases must explicitly push on the brake pedal, often requesting a strong negative torque. This enhanced driver model is out of the scope of the EHPTlib library.</p>
</body></html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -40}, {100, 40}}, preserveAspectRatio = false), graphics = {Rectangle(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-84, 36}, {-24, 4}}), Text(origin = {-6, 0}, lineColor = {28, 108, 200}, pattern = LinePattern.Dash, extent = {{-82, 2}, {-26, -4}}, textString = "electric drive")}),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StopTime = 200, Interval = 0.1),
        __OpenModelica_simulationFlags(jacobian = "", s = "dassl", lv = "LOG_STATS"),
        __OpenModelica_commandLineOptions = "");
    end FirstEVAngle;

    model MBEV "Simulates a very basic Electric Vehicle"
      import Modelica;
      extends Modelica.Icons.Example;
      Modelica.Units.SI.Energy enBatDel;
      Modelica.Units.SI.Energy enDTdel;
      Modelica.Units.SI.Energy enP1del;
      Modelica.Units.SI.Energy enBattLoss;
      Modelica.Units.SI.Energy enBraking;
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 6) annotation (
        Placement(visible = true, transformation(origin = {-20, 14}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, yMax = 100000.0, k = 100) annotation (
        Placement(visible = true, transformation(extent = {{-116, -10}, {-96, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.5715) annotation (
        Placement(visible = true, transformation(extent = {{-4, 4}, {16, 24}}, rotation = 0)));
      EHPTlib.MapBased.OneFlange eleDrive(J = 0.25, effTableName = "effTable", mapsFileName = "EVmaps.txt", mapsOnFile = true, tauMax = 150, wMax = 500) "Electric Drive" annotation (
        Placement(visible = true, transformation(extent = {{-74, 6}, {-54, 24}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.Batt1 batt1(SOCInit = 0.7, QCellNom = 100 * 3600, ns = 100) annotation (
        Placement(transformation(extent = {{-112, 34}, {-92, 54}})));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(extent = {{-84, -20}, {-64, 0}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP1 annotation (
        Placement(visible = true, transformation(origin = {32, 14}, extent = {{-6, -8}, {6, 8}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{56, 4}, {76, 24}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor pP2 annotation (
        Placement(visible = true, transformation(origin = {98, 4}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor velSens annotation (
        Placement(visible = true, transformation(origin = {68, -42}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragF(Cx = 0.26, rho = 1.226, S = 2.2, fc = 0.014, m = mass.m) annotation (
        Placement(visible = true, transformation(origin = {98, -24}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Translational.Sources.Force brake annotation (
        Placement(visible = true, transformation(origin = {32, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Sensors.TorqueSensor edTau annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 0, origin = {-42, 14})));
      Modelica.Blocks.Math.Add add(k1 = -1) annotation (
        Placement(transformation(extent = {{-42, -26}, {-30, -14}})));
      Modelica.Blocks.Math.Gain tqToForce(k = gear.ratio * wheel.radius) annotation (
        Placement(visible = true, transformation(extent = {{0, -26}, {12, -14}}, rotation = 0)));
      Modelica.Blocks.Nonlinear.Limiter cutNeg(uMax=0, uMin=-Modelica.Constants.inf)
        annotation (Placement(visible=true, transformation(
            origin={-14,-20},
            extent={{-6,-6},{6,6}},
            rotation=0)));
    equation
      connect(batt1.n, eleDrive.pin_n) annotation (
        Line(points = {{-91.9, 38}, {-80, 38}, {-80, 10}, {-74, 10}}, color = {0, 0, 255}));
      connect(eleDrive.pin_n, ground.p) annotation (
        Line(points = {{-74, 10}, {-74, 10}, {-74, 0}, {-74, 0}}, color = {0, 0, 255}));
      connect(eleDrive.tauRef, driver.tauRef) annotation (
        Line(points = {{-75.4, 14}, {-86, 14}, {-86, 0}, {-95, 0}}, color = {0, 0, 127}));
      connect(batt1.p, eleDrive.pin_p) annotation (
        Line(points = {{-92, 50}, {-74, 50}, {-74, 18}}, color = {0, 0, 255}));
      connect(edTau.flange_a, eleDrive.flange_a) annotation (
        Line(points = {{-50, 14}, {-54, 14}}));
      connect(tqToForce.y, brake.f) annotation (
        Line(points = {{12.6, -20}, {18, -20}, {18, -20}, {20, -20}}, color = {0, 0, 127}));
      connect(cutNeg.y, tqToForce.u) annotation (
        Line(points = {{-7.4, -20}, {-2, -20}, {-2, -20}, {-1.2, -20}}, color = {0, 0, 127}));
      connect(cutNeg.u, add.y) annotation (
        Line(points = {{-21.2, -20}, {-30, -20}, {-30, -20}, {-29.4, -20}}, color = {0, 0, 127}));
      connect(brake.flange, pP1.flange_b) annotation (
        Line(points = {{42, -20}, {46, -20}, {46, 14}, {38, 14}}, color = {0, 127, 0}));
      connect(velSens.flange, pP2.flange_a) annotation (
        Line(points = {{78, -42}, {78, 14}, {98, 14}}, color = {0, 127, 0}));
      connect(driver.V, velSens.v) annotation (
        Line(points = {{-106, -11.2}, {-106, -42}, {57, -42}}, color = {0, 0, 127}));
      connect(mass.flange_a, pP1.flange_b) annotation (
        Line(points = {{56, 14}, {38, 14}}, color = {0, 127, 0}));
      connect(pP2.flange_a, mass.flange_b) annotation (
        Line(points = {{98, 14}, {76, 14}}, color = {0, 127, 0}));
      connect(pP1.flange_a, wheel.flangeT) annotation (
        Line(points = {{26, 14}, {16, 14}}, color = {0, 127, 0}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-10, 14}, {-4, 14}}));
      connect(dragF.flange, pP2.flange_b) annotation (
        Line(points = {{98, -14}, {98, -6}}, color = {0, 127, 0}));
      der(enBatDel) = (batt1.p.v - batt1.n.v) * batt1.n.i;
      der(enDTdel) = eleDrive.powSensor.power;
      der(enP1del) = pP1.power;
      der(enBattLoss) = batt1.powerLoss;
      der(enBraking) = if pP1.power > 0 then 0 else -pP1.power;
      connect(add.u2, driver.tauRef) annotation (
        Line(points = {{-43.2, -23.6}, {-86, -23.6}, {-86, 0}, {-95, 0}}, color = {0, 0, 127}));
      connect(edTau.flange_b, gear.flange_a) annotation (
        Line(points = {{-34, 14}, {-30, 14}, {-30, 14}}, color = {0, 0, 0}));
      connect(add.u1, edTau.tau) annotation (
        Line(points = {{-43.2, -16.4}, {-48.4, -16.4}, {-48.4, 5.2}}, color = {0, 0, 127}));
      annotation (
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>Simple map-based EV model with battery.</p>
</html>"),
        Commands,
        Diagram(coordinateSystem(extent = {{-120, -60}, {120, 60}}, preserveAspectRatio = false)),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 0.1),
        __OpenModelica_commandLineOptions = "");
    end MBEV;
  end EV;

  package sHEV
    model SHEVpowerFilt "Ice, Generator, DriveTrain, all map-based"
     extends Modelica.Icons.Example;
      Modelica.Electrical.Analog.Basic.Ground ground1 annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 0, origin = {-42, -2})));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.473) annotation (
        Placement(transformation(extent = {{-52, -46}, {-38, -32}})));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 10) annotation (
        Placement(transformation(extent = {{-78, -46}, {-64, -32}})));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 14000) annotation (
        Placement(transformation(extent = {{-8, -48}, {10, -30}})));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powProp annotation (
        Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 0, origin = {-23, -39})));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powDrag annotation (
        Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 0, origin = {45, -39})));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(S = 6.5, fc = 0.01, Cx = 0.65, m = mass.m) annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 90, origin = {80, -48})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor1 annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 270, origin = {26, -54})));
      Modelica.Blocks.Continuous.FirstOrder powFilt(y_start = 20e3, T = 500) annotation (
        Placement(visible = true, transformation(extent = {{12, 64}, {-4, 80}}, rotation = 0)));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax = 100e3, uMin = 0) annotation (
        Placement(visible = true, transformation(extent = {{-14, 64}, {-30, 80}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "Sort1.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 500.0, yMax = 2e3) annotation (
        Placement(visible = true, transformation(extent = {{-94, 76}, {-74, 96}}, rotation = 0)));
      EHPTlib.MapBased.Genset genset(gsRatio = 1, mapsFileName = "SHEVmaps.txt", maxGenW = 300, maxPow = 45000, maxTau = 500, wIceStart = 300) annotation (
        Placement(transformation(extent = {{-80, 8}, {-50, 38}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1 battery(ICellMax = 500, QCellNom = 25 * 3600, R0Cell = 0.35E-3, efficiency = 0.9, iCellEfficiency = 100, ns = 100) annotation (
        Placement(visible = true, transformation(extent = {{0, 20}, {20, 40}}, rotation = 0)));
      EHPTlib.MapBased.OneFlange drive(effTableName = "motEffTable", mapsFileName = "SHEVmaps.txt", mapsOnFile = false, powMax = 150e3, tauMax = 1000, wMax = 3000) annotation (
        Placement(visible = true, transformation(extent = {{68, 42}, {88, 22}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor gsPow annotation (
        Placement(visible = true, transformation(extent = {{-32, 24}, {-12, 44}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor drivePow annotation (
        Placement(visible = true, transformation(origin = {52, 36}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(battery.n, drivePow.nv) annotation (
        Line(points = {{20.1, 24}, {24, 24}, {24, 14}, {52, 14}, {52, 26}, {52, 26}}, color = {0, 0, 255}));
      connect(drive.pin_p, drivePow.nv) annotation (
        Line(points = {{68, 28.6667}, {61, 28.6667}, {61, 26}, {52, 26}}, color = {0, 0, 255}));
      connect(drivePow.nc, drive.pin_n) annotation (
        Line(points = {{62, 36}, {66, 36}, {66, 37.5556}, {68, 37.5556}}, color = {0, 0, 255}));
      connect(gear.flange_a, drive.flange_a) annotation (
        Line(points = {{-78, -39}, {-84, -39}, {-84, -14}, {98, -14}, {98, 33.1111}, {88, 33.1111}}));
      connect(drive.tauRef, driver.tauRef) annotation (
        Line(points = {{66.6, 33.1111}, {66.6, 32}, {32, 32}, {32, 86}, {-73, 86}}, color = {0, 0, 127}));
      connect(gsPow.nv, genset.pin_n) annotation (
        Line(points = {{-22, 24}, {-22, 24}, {-22, 14}, {-49.7, 14}, {-49.7, 14}}, color = {0, 0, 255}));
      connect(gsPow.pv, gsPow.pc) annotation (
        Line(points = {{-22, 44}, {-32, 44}, {-32, 34}}, color = {0, 0, 255}));
      connect(gsPow.pc, genset.pin_p) annotation (
        Line(points = {{-32, 34}, {-41, 34}, {-41, 32}, {-50, 32}}, color = {0, 0, 255}));
      connect(gsPow.nc, battery.p) annotation (
        Line(points = {{-12, 34}, {-8, 34}, {-8, 48}, {20, 48}, {20, 36}}, color = {0, 0, 255}));
      connect(drivePow.power, powFilt.u) annotation (
        Line(points = {{42, 25}, {38, 25}, {38, 72}, {13.6, 72}, {13.6, 72}}, color = {0, 0, 127}));
      connect(drivePow.nv, genset.pin_n) annotation (
        Line(points = {{52, 26}, {52, 14}, {-49.7, 14}}, color = {0, 0, 255}));
      connect(drivePow.pv, drivePow.pc) annotation (
        Line(points = {{52, 46}, {42, 46}, {42, 36}, {42, 36}}, color = {0, 0, 255}));
      connect(drivePow.pc, battery.p) annotation (
        Line(points = {{42, 36}, {20, 36}, {20, 36}, {20, 36}}, color = {0, 0, 255}));
      connect(powFilt.y, limiter.u) annotation (
        Line(points = {{-4.8, 72}, {-12.4, 72}}, color = {0, 0, 127}));
      connect(limiter.y, genset.powRef) annotation (
        Line(points = {{-30.8, 72}, {-55.85, 72}, {-55.85, 40.25}}, color = {0, 0, 127}));
      connect(speedSensor1.v, driver.V) annotation (
        Line(points = {{26, -62.8}, {26, -74}, {-94, -74}, {-94, 68}, {-84, 68}, {-84, 74.8}}, color = {0, 0, 127}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-64, -39}, {-52, -39}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(mass.flange_a, powProp.flange_b) annotation (
        Line(points = {{-8, -39}, {-16, -39}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powProp.flange_a, wheel.flangeT) annotation (
        Line(points = {{-30, -39}, {-38, -39}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powDrag.flange_a, mass.flange_b) annotation (
        Line(points = {{38, -39}, {10, -39}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powDrag.flange_b, dragForce.flange) annotation (
        Line(points = {{52, -39}, {66, -39}, {66, -40}, {80, -40}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(speedSensor1.flange, mass.flange_b) annotation (
        Line(points = {{26, -46}, {26, -39}, {10, -39}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(genset.pin_n, ground1.p) annotation (
        Line(points = {{-49.7, 14}, {-42, 14}, {-42, 6}}, color = {0, 0, 255}, smooth = Smooth.None));
      annotation (
        Diagram(coordinateSystem(extent = {{-100, -80}, {100, 100}}, initialScale = 0.1), graphics = {Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-90, -28}, {94, -70}}), Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-90, 52}, {94, -10}}), Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-60, 96}, {94, 58}}), Text(lineColor = {255, 0, 0}, fillPattern = FillPattern.Solid, extent = {{68, 74}, {94, 66}}, textString = "EMS"), Text(lineColor = {255, 0, 0}, extent = {{-96, -60}, {-44, -68}}, textString = "Longitudinal Dynamics"), Text(lineColor = {255, 0, 0}, fillPattern = FillPattern.Solid, extent = {{12, 0}, {58, -8}}, textString = "PowerTrain")}),
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics),
        experiment(StopTime = 400, StartTime = 0, Tolerance = 1e-06, Interval = 0.2),
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>This is a SHEV model which has an Energy Management System able to control the power flow with basic logic: requests the ICE to deliver the average load power.</p>
</html>"));
    end SHEVpowerFilt;

    model SHEVpowerFiltSoc "Ice, Generator, DriveTrain, all map-based"
      //€
      extends Modelica.Icons.Example;
      Modelica.Electrical.Analog.Basic.Ground ground1 annotation (
        Placement(visible = true, transformation(origin = {-40, -22}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.473) annotation (
        Placement(transformation(extent = {{-52, -66}, {-40, -54}})));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 10) annotation (
        Placement(transformation(extent = {{-78, -66}, {-66, -54}})));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 14000) annotation (
        Placement(transformation(extent = {{-8, -68}, {10, -50}})));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powProp annotation (
        Placement(transformation(extent = {{-6, -6}, {6, 6}}, rotation = 0, origin = {-24, -60})));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powDrag annotation (
        Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 0, origin = {45, -59})));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(S = 6.5, fc = 0.01, Cx = 0.65, m = mass.m) annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 90, origin = {80, -68})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor1 annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 270, origin = {26, -74})));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "Sort1.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 200.0, yMax = 2e3) annotation (
        Placement(visible = true, transformation(extent = {{-100, 90}, {-80, 110}}, rotation = 0)));
      EHPTlib.MapBased.Genset genset(gsRatio = 1, mapsFileName = "SHEVmaps.txt", maxGenW = 300, maxPow = 45000, maxTau = 500, wIceStart = 300) annotation (
        Placement(transformation(extent = {{-80, -34}, {-50, -4}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1 battery(ICellMax = 500, QCellNom = 25 * 3600, R0Cell = 0.35E-3, efficiency = 0.9, iCellEfficiency = 200, ns = 200) annotation (
        Placement(transformation(extent = {{0, -24}, {20, -4}})));
      EHPTlib.MapBased.OneFlange drive(effTableName = "motEffTable", mapsFileName = "SHEVmaps.txt", mapsOnFile = false, powMax = 150e3, tauMax = 1000, wMax = 3000) annotation (
        Placement(visible = true, transformation(extent = {{66, -10}, {86, -30}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor gsPow annotation (
        Placement(transformation(extent = {{-32, -20}, {-12, 0}})));
      Modelica.Blocks.Math.Feedback fbSOC annotation (
        Placement(transformation(extent = {{20, 38}, {0, 58}})));
      Modelica.Blocks.Sources.Constant socRef_(k = 0.5) annotation (
        Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = 180, origin = {38, 48})));
      Modelica.Blocks.Math.Gain socErrToPow(k = 3e6) annotation (
        Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 0, origin = {-24, 48})));
      Modelica.Blocks.Math.Add add annotation (
        Placement(visible = true, transformation(origin = {-6, 80}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      Modelica.Blocks.Continuous.FirstOrder powFilt(y_start = 20e3, T = 500) annotation (
        Placement(visible = true, transformation(extent = {{34, 78}, {18, 94}}, rotation = 0)));
      Modelica.Blocks.Nonlinear.Limiter toPowRef(uMax = 100e3, uMin = 0) annotation (
        Placement(visible = true, transformation(extent = {{-30, 72}, {-46, 88}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor drivePow annotation (
        Placement(visible = true, transformation(origin = {50, -8}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(add.y, toPowRef.u) annotation (
        Line(points = {{-17, 80}, {-28.4, 80}}, color = {0, 0, 127}));
      connect(genset.pin_n, ground1.p) annotation (
        Line(points = {{-49.7, -28}, {-45.85, -28}, {-45.85, -14}, {-40, -14}}, color = {0, 0, 255}));
      connect(gsPow.nv, genset.pin_n) annotation (
        Line(points = {{-22, -20}, {-22, -28}, {-49.7, -28}}, color = {0, 0, 255}));
      connect(drivePow.nv, drive.pin_p) annotation (
        Line(points = {{50, -18}, {50, -23.3333}, {66, -23.3333}}, color = {0, 0, 255}));
      connect(drivePow.pc, battery.p) annotation (
        Line(points = {{40, -8}, {20, -8}}, color = {0, 0, 255}));
      connect(drivePow.pv, drivePow.pc) annotation (
        Line(points = {{50, 2}, {40, 2}, {40, -8}}, color = {0, 0, 255}));
      connect(drivePow.nc, drive.pin_n) annotation (
        Line(points = {{60, -8}, {66, -8}, {66, -14.4444}}, color = {0, 0, 255}));
      connect(gear.flange_a, drive.flange_a) annotation (
        Line(points = {{-78, -60}, {-84, -60}, {-84, -42}, {96, -42}, {96, -18.8889}, {86, -18.8889}}));
      connect(drive.tauRef, driver.tauRef) annotation (
        Line(points = {{64.6, -18.8889}, {64.6, 16}, {64, 16}, {64, 24}, {82, 24}, {82, 100}, {-79, 100}}, color = {0, 0, 127}));
      connect(battery.n, drive.pin_p) annotation (
        Line(points = {{20.1, -20}, {24, -20}, {24, -28}, {32, -28}, {32, -23.3333}, {66, -23.3333}}, color = {0, 0, 255}));
      connect(gsPow.nv, drive.pin_p) annotation (
        Line(points = {{-22, -20}, {-22, -28}, {32, -28}, {32, -23.3333}, {66, -23.3333}}, color = {0, 0, 255}));
      connect(socErrToPow.y, add.u2) annotation (
        Line(points = {{-35, 48}, {-46, 48}, {-46, 66}, {12, 66}, {12, 74}, {6, 74}}, color = {0, 0, 127}));
      connect(toPowRef.y, genset.powRef) annotation (
        Line(points = {{-46.8, 80}, {-56, 80}, {-56, -1.75}, {-55.85, -1.75}}, color = {0, 0, 127}));
      connect(powFilt.y, add.u1) annotation (
        Line(points = {{17.2, 86}, {6, 86}}, color = {0, 0, 127}));
      connect(speedSensor1.v, driver.V) annotation (
        Line(points = {{26, -82.8}, {26, -82}, {-94, -82}, {-94, 40}, {-90, 40}, {-90, 88.8}}, color = {0, 0, 127}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-66, -60}, {-52, -60}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(mass.flange_a, powProp.flange_b) annotation (
        Line(points = {{-8, -59}, {-12, -59}, {-12, -60}, {-18, -60}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powProp.flange_a, wheel.flangeT) annotation (
        Line(points = {{-30, -60}, {-40, -60}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powDrag.flange_a, mass.flange_b) annotation (
        Line(points = {{38, -59}, {10, -59}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(powDrag.flange_b, dragForce.flange) annotation (
        Line(points = {{52, -59}, {66, -59}, {66, -60}, {80, -60}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(speedSensor1.flange, mass.flange_b) annotation (
        Line(points = {{26, -66}, {26, -59}, {10, -59}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(gsPow.pc, genset.pin_p) annotation (
        Line(points = {{-32, -10}, {-50, -10}}, color = {0, 0, 255}));
      connect(gsPow.nc, battery.p) annotation (
        Line(points = {{-12, -10}, {-8, -10}, {-8, 6}, {28, 6}, {28, -8}, {20, -8}}, color = {0, 0, 255}));
      connect(gsPow.pv, gsPow.pc) annotation (
        Line(points = {{-22, 0}, {-32, 0}, {-32, -10}}, color = {0, 0, 255}));
      connect(battery.SOC, fbSOC.u2) annotation (
        Line(points = {{-1, -14}, {-4, -14}, {-4, 40}, {10, 40}}, color = {0, 0, 127}));
      connect(fbSOC.u1, socRef_.y) annotation (
        Line(points = {{18, 48}, {27, 48}}, color = {0, 0, 127}));
      connect(socErrToPow.u, fbSOC.y) annotation (
        Line(points = {{-12, 48}, {1, 48}}, color = {0, 0, 127}));
      connect(drivePow.power, powFilt.u) annotation (
        Line(points = {{40, -19}, {40, -18}, {34, -18}, {34, 26}, {60, 26}, {60, 86}, {35.6, 86}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(extent = {{-100, -100}, {100, 120}}, initialScale = 0.1), graphics = {Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-90, -48}, {94, -94}}), Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-90, 10}, {92, -38}}), Rectangle(lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-70, 116}, {94, 30}}), Text(lineColor = {255, 0, 0}, fillPattern = FillPattern.Solid, extent = {{50, 112}, {76, 104}}, textString = "EMS"), Text(origin = {16, -4}, lineColor = {255, 0, 0}, extent = {{-96, -80}, {-44, -88}}, textString = "Longitudinal Dynamics"), Text(origin = {-9.3846, 46}, lineColor = {255, 0, 0}, extent = {{-88.6154, -40}, {-40.6154, -44}}, textString = "Power Train")}),
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 120}}, initialScale = 0.1), graphics),
        experiment(StopTime = 2000, StartTime = 0, Tolerance = 1e-06, Interval = 4),
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>This is a SHEV model which has an Energy Management System able to control the power flow with:</p>
<p>- basic logic: requests the ICE to deliver the average load power </p>
<p>- additional logic: SOC loop to avoid SOC drift.</p>
</html>"));
    end SHEVpowerFiltSoc;

    model SHEV_OO "Ice, Generator, DriveTrain, all map-based"
      //€
      extends Modelica.Icons.Example;
      Modelica.Electrical.Analog.Basic.Ground ground1 annotation (
        Placement(visible = true, transformation(origin = {22, -12}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.473) annotation (
        Placement(visible = true, transformation(origin = {-48, -42}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 10) annotation (
        Placement(visible = true, transformation(extent = {{-82, -52}, {-62, -32}}, rotation = 0)));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 14000) annotation (
        Placement(visible = true, transformation(extent = {{-2, -50}, {16, -32}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powProp annotation (
        Placement(visible = true, transformation(origin = {-21, -41}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
      Modelica.Mechanics.Translational.Sensors.PowerSensor powDrag annotation (
        Placement(visible = true, transformation(origin = {51, -41}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(S = 6.5, fc = 0.01, Cx = 0.65, m = mass.m) annotation (
        Placement(visible = true, transformation(origin = {76, -50}, extent = {{-8, -8}, {8, 8}}, rotation = 90)));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor1 annotation (
        Placement(visible = true, transformation(origin = {26, -56}, extent = {{-8, -8}, {8, 8}}, rotation = 270)));
      EHPTlib.SupportModels.Miscellaneous.Batt1 battery(ICellMax = 500, QCellNom = 25 * 3600, R0Cell = 0.35E-3, SOCInit = 0.5, efficiency = 0.9, iCellEfficiency = 200, ns = 100) annotation (
        Placement(visible = true, transformation(origin = {-2, 26}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      EHPTlib.MapBased.OneFlange drive(effTableName = "motEffTable", mapsFileName = "SHEVmaps.txt", mapsOnFile = false, powMax = 150e3, tauMax = 1000, wMax = 3000) annotation (
        Placement(visible = true, transformation(extent = {{64, 16}, {84, -4}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor gsPow annotation (
        Placement(visible = true, transformation(extent = {{-36, 0}, {-16, 20}}, rotation = 0)));
      EHPTlib.MapBased.ECUs.EMS ems(powHigh = 60e3, powLow = 30e3, powMax = 200e3, powPerSoc = 300e3, socRef = 0.6) annotation (
        Placement(visible = true, transformation(origin = {-20, 58}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      EHPTlib.MapBased.GensetOO genset(gsRatio = 1, mapsFileName = "SHEVmaps.txt", maxGenW = 300, maxPow = 45000, maxTau = 500, wIceStart = 300) annotation (
        Placement(visible = true, transformation(extent = {{-84, -14}, {-54, 16}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "Sort1.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 200.0, yMax = 2e3) annotation (
        Placement(visible = true, transformation(origin = {86, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      Modelica.Electrical.Analog.Sensors.PowerSensor drivePow annotation (
        Placement(visible = true, transformation(origin = {40, 16}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(genset.pin_n, drive.pin_p) annotation (
        Line(points = {{-53.7, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
      connect(gsPow.pc, genset.pin_p) annotation (
        Line(points = {{-36, 10}, {-54, 10}}, color = {0, 0, 255}));
      connect(ems.pcPowReq, genset.powRef) annotation (
        Line(points = {{-30.8, 52}, {-60, 52}, {-60, 18.4}}, color = {0, 0, 127}));
      connect(ems.on, genset.ON) annotation (
        Line(points = {{-30.8, 64}, {-78, 64}, {-78, 18.4}}, color = {255, 0, 255}));
      connect(drive.flange_a, gear.flange_a) annotation (
        Line(points = {{84, 7.11111}, {94, 7.11111}, {94, -24}, {-94, -24}, {-94, -42}, {-82, -42}, {-82, -42}, {-82, -42}}));
      connect(drivePow.power, ems.edPow) annotation (
        Line(points = {{32, 5}, {16, 5}, {16, 64}, {-8, 64}, {-8, 64}}, color = {0, 0, 127}));
      connect(drivePow.nv, drive.pin_p) annotation (
        Line(points = {{40, 6}, {40, 6}, {40, 0}, {64, 0}, {64, 2.66667}}, color = {0, 0, 255}));
      connect(drivePow.pc, battery.p) annotation (
        Line(points = {{30, 16}, {4, 16}, {4, 16}, {4, 16}}, color = {0, 0, 255}));
      connect(drivePow.pv, drivePow.nc) annotation (
        Line(points = {{40, 26}, {50, 26}, {50, 16}, {50, 16}}, color = {0, 0, 255}));
      connect(drivePow.nc, drive.pin_n) annotation (
        Line(points = {{50, 16}, {64, 16}, {64, 11.5556}, {64, 11.5556}}, color = {0, 0, 255}));
      connect(driver.tauRef, drive.tauRef) annotation (
        Line(points = {{75, 60}, {57, 60}, {57, 4.5}, {62.6, 4.5}, {62.6, 7.11111}}, color = {0, 0, 127}));
      connect(ground1.p, drive.pin_p) annotation (
        Line(points = {{22, -4}, {22, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
      connect(gsPow.nv, drive.pin_p) annotation (
        Line(points = {{-26, 0}, {-26, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
      connect(battery.n, drive.pin_p) annotation (
        Line(points = {{-8, 15.9}, {-8, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
      connect(speedSensor1.v, driver.V) annotation (
        Line(points = {{26, -64.8}, {26, -74}, {98, -74}, {98, 44}, {86, 44}, {86, 48.8}}, color = {0, 0, 127}));
      connect(gear.flange_b, wheel.flangeR) annotation (
        Line(points = {{-62, -42}, {-56, -42}}));
      connect(powProp.flange_a, wheel.flangeT) annotation (
        Line(points = {{-30, -41}, {-35, -41}, {-35, -42}, {-40, -42}}, color = {0, 127, 0}));
      connect(mass.flange_a, powProp.flange_b) annotation (
        Line(points = {{-2, -41}, {-12, -41}}, color = {0, 127, 0}));
      connect(battery.SOC, ems.soc) annotation (
        Line(points = {{-2, 37}, {-2, 52}, {-8, 52}}, color = {0, 0, 127}));
      connect(gsPow.pv, gsPow.pc) annotation (
        Line(points = {{-26, 20}, {-36, 20}, {-36, 10}}, color = {0, 0, 255}));
      connect(powDrag.flange_b, dragForce.flange) annotation (
        Line(points = {{60, -41}, {60, -42}, {76, -42}}, color = {0, 127, 0}));
      connect(speedSensor1.flange, mass.flange_b) annotation (
        Line(points = {{26, -48}, {26, -41}, {16, -41}}, color = {0, 127, 0}));
      connect(powDrag.flange_a, mass.flange_b) annotation (
        Line(points = {{42, -41}, {42, -41}, {16, -41}}, color = {0, 127, 0}));
      connect(battery.p, gsPow.nc) annotation (
        Line(points = {{4, 16}, {4, 10}, {-16, 10}}, color = {0, 0, 255}));
      annotation (
        Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, initialScale = 0.1), graphics = {Rectangle(origin = {-2, 4}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-88, -32}, {94, -74}}), Rectangle(origin = {-4, 0}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-88, 40}, {94, -20}}), Text(origin = {0, 4}, lineColor = {255, 0, 0}, fillPattern = FillPattern.Solid, extent = {{-96, -64}, {-44, -72}}, textString = "MechProp")}),
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics),
        experiment(StopTime = 2000, StartTime = 0, Tolerance = 1e-06, Interval = 0.4),
        experimentSetupOutput(derivatives = false),
        Documentation(info = "<html>
<p>This is a SHEV model which has an Energy Management System able to control the power flow with:</p>
<p>- basic logic: requests the ICE to deliver the average load power </p>
<p>- additional logic: SOC loop to avoid SOC drift</p>
<p>- further ON/OFF control to switch OFF the engine when the average power is too low to permit efficient operation.</p>
</html>"),
        __OpenModelica_commandLineOptions = "");
    end SHEV_OO;

    package Proposte
      model BusAcc "Ice, Generator, DriveTrain, all map-based"
        //€
        extends Modelica.Icons.Example;
        Modelica.Electrical.Analog.Basic.Ground ground1 annotation (
          Placement(visible = true, transformation(origin = {22, -12}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.473) annotation (
          Placement(visible = true, transformation(origin = {-48, -42}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 10) annotation (
          Placement(visible = true, transformation(extent = {{-82, -52}, {-62, -32}}, rotation = 0)));
        Modelica.Mechanics.Translational.Components.Mass mass(m = 14000) annotation (
          Placement(visible = true, transformation(extent = {{-2, -50}, {16, -32}}, rotation = 0)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor powProp annotation (
          Placement(visible = true, transformation(origin = {-21, -41}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor powDrag annotation (
          Placement(visible = true, transformation(origin = {51, -41}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(S = 6.5, fc = 0.01, Cx = 0.65, m = mass.m) annotation (
          Placement(visible = true, transformation(origin = {76, -50}, extent = {{-8, -8}, {8, 8}}, rotation = 90)));
        Modelica.Mechanics.Translational.Sensors.SpeedSensor speedSensor1 annotation (
          Placement(visible = true, transformation(origin = {26, -56}, extent = {{-8, -8}, {8, 8}}, rotation = 270)));
        EHPTlib.SupportModels.Miscellaneous.Batt1 battery(ICellMax = 1000, QCellNom = 25 * 3600, R0Cell = 0.35E-3, SOCInit = 0.5, efficiency = 0.9, iCellEfficiency = 200, ns = 100) annotation (
          Placement(visible = true, transformation(origin = {-2, 26}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        EHPTlib.MapBased.OneFlange drive(effTableName = "motEffTable", mapsFileName = "SHEVmaps.txt", mapsOnFile = false, powMax = 150e3, tauMax = 1000, wMax = 3000) annotation (
          Placement(visible = true, transformation(extent = {{64, 16}, {84, -4}}, rotation = 0)));
        Modelica.Electrical.Analog.Sensors.PowerSensor gsPow annotation (
          Placement(visible = true, transformation(extent = {{-36, 0}, {-16, 20}}, rotation = 0)));
        EHPTlib.MapBased.ECUs.EMS ems(powHigh = 60e3, powLow = 30e3, powMax = 200e3, powPerSoc = 300e3, socRef = 0.6) annotation (
          Placement(visible = true, transformation(origin = {-20, 58}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
        EHPTlib.MapBased.GensetOO genset(gsRatio = 1, mapsFileName = "SHEVmaps.txt") annotation (
          Placement(visible = true, transformation(extent = {{-84, -14}, {-54, 16}}, rotation = 0)));
        EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "BusAcc.txt", extrapolation = Modelica.Blocks.Types.Extrapolation.Periodic, k = 400.0, yMax = 2e3) annotation (
          Placement(visible = true, transformation(origin = {86, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
        Modelica.Electrical.Analog.Sensors.PowerSensor drivePow annotation (
          Placement(visible = true, transformation(origin = {40, 16}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      equation
        connect(genset.pin_n, drive.pin_p) annotation (
          Line(points = {{-53.7, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
        connect(gsPow.pc, genset.pin_p) annotation (
          Line(points = {{-36, 10}, {-54, 10}}, color = {0, 0, 255}));
        connect(ems.pcPowReq, genset.powRef) annotation (
          Line(points = {{-30.8, 52}, {-60, 52}, {-60, 18.4}}, color = {0, 0, 127}));
        connect(ems.on, genset.ON) annotation (
          Line(points = {{-30.8, 64}, {-78, 64}, {-78, 18.4}}, color = {255, 0, 255}));
        connect(drive.flange_a, gear.flange_a) annotation (
          Line(points = {{84, 7.11111}, {94, 7.11111}, {94, -24}, {-94, -24}, {-94, -42}, {-82, -42}, {-82, -42}, {-82, -42}}));
        connect(drivePow.power, ems.edPow) annotation (
          Line(points = {{32, 5}, {16, 5}, {16, 64}, {-8, 64}, {-8, 64}}, color = {0, 0, 127}));
        connect(drivePow.nv, drive.pin_p) annotation (
          Line(points = {{40, 6}, {40, 6}, {40, 0}, {64, 0}, {64, 2.66667}}, color = {0, 0, 255}));
        connect(drivePow.pc, battery.p) annotation (
          Line(points = {{30, 16}, {4, 16}, {4, 16}, {4, 16}}, color = {0, 0, 255}));
        connect(drivePow.pv, drivePow.nc) annotation (
          Line(points = {{40, 26}, {50, 26}, {50, 16}, {50, 16}}, color = {0, 0, 255}));
        connect(drivePow.nc, drive.pin_n) annotation (
          Line(points = {{50, 16}, {64, 16}, {64, 11.5556}, {64, 11.5556}}, color = {0, 0, 255}));
        connect(driver.tauRef, drive.tauRef) annotation (
          Line(points = {{75, 60}, {57, 60}, {57, 4.5}, {62.6, 4.5}, {62.6, 7.11111}}, color = {0, 0, 127}));
        connect(ground1.p, drive.pin_p) annotation (
          Line(points = {{22, -4}, {22, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
        connect(gsPow.nv, drive.pin_p) annotation (
          Line(points = {{-26, 0}, {-26, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
        connect(battery.n, drive.pin_p) annotation (
          Line(points = {{-8, 15.9}, {-8, -8}, {10, -8}, {10, 2.66667}, {64, 2.66667}}, color = {0, 0, 255}));
        connect(speedSensor1.v, driver.V) annotation (
          Line(points = {{26, -64.8}, {26, -74}, {98, -74}, {98, 44}, {86, 44}, {86, 48.8}}, color = {0, 0, 127}));
        connect(gear.flange_b, wheel.flangeR) annotation (
          Line(points = {{-62, -42}, {-56, -42}}));
        connect(powProp.flange_a, wheel.flangeT) annotation (
          Line(points = {{-30, -41}, {-35, -41}, {-35, -42}, {-40, -42}}, color = {0, 127, 0}));
        connect(mass.flange_a, powProp.flange_b) annotation (
          Line(points = {{-2, -41}, {-12, -41}}, color = {0, 127, 0}));
        connect(battery.SOC, ems.soc) annotation (
          Line(points = {{-2, 37}, {-2, 52}, {-8, 52}}, color = {0, 0, 127}));
        connect(gsPow.pv, gsPow.pc) annotation (
          Line(points = {{-26, 20}, {-36, 20}, {-36, 10}}, color = {0, 0, 255}));
        connect(powDrag.flange_b, dragForce.flange) annotation (
          Line(points = {{60, -41}, {60, -42}, {76, -42}}, color = {0, 127, 0}));
        connect(speedSensor1.flange, mass.flange_b) annotation (
          Line(points = {{26, -48}, {26, -41}, {16, -41}}, color = {0, 127, 0}));
        connect(powDrag.flange_a, mass.flange_b) annotation (
          Line(points = {{42, -41}, {42, -41}, {16, -41}}, color = {0, 127, 0}));
        connect(battery.p, gsPow.nc) annotation (
          Line(points = {{4, 16}, {4, 10}, {-16, 10}}, color = {0, 0, 255}));
        annotation (
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, initialScale = 0.1), graphics = {Rectangle(origin = {-2, 4}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-88, -32}, {94, -74}}), Rectangle(origin = {-4, 0}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-88, 40}, {94, -20}}), Text(origin = {0, 4}, lineColor = {255, 0, 0}, fillPattern = FillPattern.Solid, extent = {{-96, -64}, {-44, -72}}, textString = "MechProp")}),
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics),
          experiment(StopTime = 2000, StartTime = 0, Tolerance = 1e-06, Interval = 0.4),
          experimentSetupOutput(derivatives = false),
          Documentation(info = "<html>
      <p>This is a SHEV model which has an Energy Management System able to control the power flow with:</p>
      <p>- basic logic: requests the ICE to deliver the average load power </p>
      <p>- additional logic: SOC loop to avoid SOC drift</p>
      <p>- further ON/OFF control to switch OFF the engine when the average power is too low to permit efficient operation.</p>
      </html>"),
          __OpenModelica_commandLineOptions = "");
      end BusAcc;
      annotation (
        Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}})));
    end Proposte;
  end sHEV;

  package PSD

    package BasicPT "Basic Power Trains"
      extends Modelica.Icons.ExamplesPackage;

      model PSBasic0 "Modello a due macchine elettriche ideali (pure inerzie)"
        import Modelica.Constants.*;
        parameter Real vMass = 1300;
        Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
          Placement(transformation(extent = {{-24, 26}, {-4, 46}})));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
          Placement(transformation(extent = {{0, 28}, {16, 44}})));
        Modelica.Mechanics.Translational.Components.Mass mass(m = 1300, v(fixed = true, start = 33.333333333333, displayUnit = "km/h")) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {28, 26})));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, S = 2.2, Cx = 0.26, m = mass.m, rho(displayUnit = "kg/m3") = 1.226) annotation (
          Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 90, origin = {27, -23})));
        Modelica.Mechanics.Rotational.Components.Inertia mot(w(fixed = false, displayUnit = "rpm"), J = 0.59) annotation (
          Placement(transformation(extent = {{-50, 26}, {-30, 46}})));
        Modelica.Mechanics.Translational.Sensors.PowerSensor Presis annotation (
          Placement(visible = true, transformation(origin = {28, -2}, extent = {{-8, -8}, {8, 8}}, rotation = 270)));
      equation
        connect(dragForce.flange, Presis.flange_b) annotation (
          Line(points = {{27, -16}, {27, -10}, {28, -10}}, color = {0, 127, 0}));
        connect(Presis.flange_a, mass.flange_b) annotation (
          Line(points = {{28, 6}, {28, 16}}, color = {0, 127, 0}));
        connect(wheel.flangeR, idealGear.flange_b) annotation (
          Line(points = {{0, 36}, {-4, 36}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(idealGear.flange_a, mot.flange_b) annotation (
          Line(points = {{-24, 36}, {-24, 38}, {-26, 38}, {-26, 36}, {-30, 36}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(wheel.flangeT, mass.flange_a) annotation (
          Line(points = {{16, 36}, {28, 36}}, color = {0, 127, 0}));
        annotation (
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html><head></head><body><h4>newInst OK</h4>
<h4>Basic model to show some funcionalitiea of a PSD-based power train</h4><p><u>Purpose f this simulation</u>:</p>
<p>to show the PSD operating points in a transient in which the vehicle decelerates as a consequence of only the resistances to movement (friction, aerodinamic drag) from &nbsp;120 km/h up to 0. The Internal Combustion Engine is kept at constant speed using a specific closed-loop control. The \"gen\" inertia is artificially enlarged, with reference to actual car's by a factor of 20. </p>
</body></html>", revisions = "<html><head></head><body>No NewInst</body></html>"),
          conversion(noneFromVersion = ""),
          Diagram(coordinateSystem(extent = {{-80, -40}, {60, 60}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Icon(coordinateSystem(extent = {{-80, -40}, {60, 60}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          experiment(StartTime = 0, StopTime = 1000, Tolerance = 0.0001, Interval = 0.5));
      end PSBasic0;

      model PSBasic1 "Modello a due macchine elettriche ideali (pure inerzie)"
        import Modelica.Constants.*;
        parameter Real vMass = 1300;
        Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-8, 0})));
        Modelica.Mechanics.Rotational.Components.Inertia ICE(J = 0.73, w(fixed = true, start = 300, displayUnit = "rad/s")) annotation (
          Placement(transformation(extent = {{-64, 14}, {-44, 34}})));
        Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
          Placement(transformation(extent = {{58, 0}, {78, 20}})));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
          Placement(transformation(extent = {{82, 2}, {98, 18}})));
        Modelica.Mechanics.Translational.Sensors.SpeedSensor vhVel annotation (
          Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 180, origin = {83, -21})));
        Modelica.Mechanics.Translational.Components.Mass mass(m = 1300, v(fixed = true, start = 33.333333333333, displayUnit = "km/h")) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {110, 0})));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, S = 2.2, Cx = 0.26, m = mass.m, rho(displayUnit = "kg/m3") = 1.226) annotation (
          Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 90, origin = {109, -49})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor iceW annotation (
          Placement(transformation(extent = {{-9, 9}, {9, -9}}, rotation = 180, origin = {1, 67})));
        Modelica.Mechanics.Rotational.Sources.Torque iceTau annotation (
          Placement(transformation(extent = {{-88, 14}, {-70, 32}})));
        Modelica.Blocks.Sources.Constant iceSetW(k = 300) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 180, origin = {-2, 40})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor sunPow annotation (
          Placement(transformation(extent = {{-46, -18}, {-26, 2}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor carrPow annotation (
          Placement(transformation(extent = {{-38, 16}, {-24, 30}})));
        Modelica.Mechanics.Rotational.Components.Inertia gen(w(fixed = false, displayUnit = "rpm"), J = 5) annotation (
          Placement(transformation(extent = {{-76, -18}, {-56, 2}})));
        Modelica.Mechanics.Rotational.Components.Inertia mot(w(fixed = false, displayUnit = "rpm"), J = 0.59) annotation (
          Placement(transformation(extent = {{32, 0}, {52, 20}})));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(transformation(extent = {{-22, 64}, {-42, 44}})));
        Modelica.Mechanics.Translational.Sensors.PowerSensor Presis annotation (
          Placement(visible = true, transformation(origin = {110, -28}, extent = {{-8, -8}, {8, 8}}, rotation = 270)));
        Modelica.Blocks.Math.Gain gain(k = 10) annotation (
          Placement(transformation(extent = {{-54, 44}, {-74, 64}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor ringPow annotation (
          Placement(transformation(extent = {{24, -8}, {8, 8}})));
      equation
        connect(dragForce.flange, Presis.flange_b) annotation (
          Line(points = {{109, -42}, {109, -36}, {110, -36}}, color = {0, 127, 0}));
        connect(vhVel.flange, Presis.flange_a) annotation (
          Line(points = {{92, -21}, {92, -20}, {110, -20}}, color = {0, 127, 0}));
        connect(Presis.flange_a, mass.flange_b) annotation (
          Line(points = {{110, -20}, {110, -10}}, color = {0, 127, 0}));
        connect(wheel.flangeR, idealGear.flange_b) annotation (
          Line(points = {{82, 10}, {78, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(iceTau.flange, ICE.flange_a) annotation (
          Line(points = {{-70, 23}, {-70, 24}, {-64, 24}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(sunPow.flange_b, PSD.sun) annotation (
          Line(points = {{-26, -8}, {-18, -8}, {-18, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(carrPow.flange_a, ICE.flange_b) annotation (
          Line(points = {{-38, 23}, {-42, 23}, {-42, 24}, {-44, 24}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(PSD.carrier, carrPow.flange_b) annotation (
          Line(points = {{-18, 4}, {-18, 23}, {-24, 23}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(carrPow.flange_b, iceW.flange) annotation (
          Line(points = {{-24, 23}, {18, 23}, {18, 67}, {10, 67}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(sunPow.flange_a, gen.flange_b) annotation (
          Line(points = {{-46, -8}, {-56, -8}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(idealGear.flange_a, mot.flange_b) annotation (
          Line(points = {{58, 10}, {58, 12}, {56, 12}, {56, 10}, {52, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(iceSetW.y, feedback.u1) annotation (
          Line(points = {{-13, 40}, {-18, 40}, {-18, 54}, {-24, 54}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(iceW.w, feedback.u2) annotation (
          Line(points = {{-8.9, 67}, {-32, 67}, {-32, 62}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(feedback.y, gain.u) annotation (
          Line(points = {{-41, 54}, {-46, 54}, {-52, 54}}, color = {0, 0, 127}));
        connect(gain.y, iceTau.tau) annotation (
          Line(points = {{-75, 54}, {-86, 54}, {-96, 54}, {-96, 23}, {-89.8, 23}}, color = {0, 0, 127}));
        connect(wheel.flangeT, mass.flange_a) annotation (
          Line(points = {{98, 10}, {110, 10}}, color = {0, 127, 0}));
        connect(mot.flange_a, ringPow.flange_a) annotation (
          Line(points = {{32, 10}, {28, 10}, {28, 0}, {24, 0}}, color = {0, 0, 0}));
        connect(PSD.ring, ringPow.flange_b) annotation (
          Line(points = {{2, 0}, {8, 0}}, color = {0, 0, 0}));
        annotation (
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<h4>newInst OK</h4>
<h4>Modello di base per mostrare le prime funzionalit&agrave; di un sistema basato su PSD.</h4>
<p><br><u>Obiettivo finale</u>: simulazione di principio di Toyota Prius </p>
<p><u>Obiettivo di questa simulazione</u>: </p>
<p>Analizzare i punti di lavoro del PSD in un transitorio in cuil il veicolo decelera a seguito solo delle resistenze al moto d 120 km/h a 0; l&apos;ICE &egrave; mantenuto a velocit&agrave; costante da uno specifico controllo in retroazione, l&apos;inerzia di gen &egrave; aumentata di un fattore 20. </p>
</html>", revisions = "<html><head></head><body>No NewInst</body></html>"),
          conversion(noneFromVersion = ""),
          Diagram(coordinateSystem(extent = {{-100, -60}, {120, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Icon(coordinateSystem(extent = {{-100, -60}, {120, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          experiment(StartTime = 0, StopTime = 1000, Tolerance = 0.0001, Interval = 0.5));
      end PSBasic1;

      model PSBasic2 "Modello a due macchine elettriche ideali (pure inerzie)"
        import Modelica.Constants.*;
        parameter Real vMass = 1300;
        parameter Real wICE = 167 "rad/s";
        Modelica.Units.SI.Power genPow0=genTau.tau*der(genTau.flange.phi);
        // rad/s
        Modelica.Blocks.Nonlinear.Limiter limTgen(uMax = 30) annotation (
          Placement(visible = true, transformation(origin = {-86, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Math.Feedback feedback1 annotation (
          Placement(visible = true, transformation(extent = {{-22, -46}, {-42, -66}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{-14, 62}, {-34, 42}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = -10) annotation (
          Placement(visible = true, transformation(extent = {{-54, -66}, {-74, -46}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sources.Torque genTau annotation (
          Placement(visible = true, transformation(extent = {{-82, -18}, {-64, 0}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia mot(w(fixed = false, displayUnit = "rpm"), J = 0.59) annotation (
          Placement(visible = true, transformation(extent = {{28, -8}, {48, 12}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia gen(w(fixed = false, displayUnit = "rpm"), J = 0.25) annotation (
          Placement(visible = true, transformation(extent = {{-58, -18}, {-38, 2}}, rotation = 0)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor propPow annotation (
          Placement(visible = true, transformation(origin = {38, -34}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor icePow annotation (
          Placement(visible = true, transformation(extent = {{-30, 12}, {-10, 32}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor genPow annotation (
          Placement(visible = true, transformation(extent = {{-32, -18}, {-12, 2}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant iceSetW(k = 300) annotation (
          Placement(visible = true, transformation(origin = {18, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Mechanics.Rotational.Sources.Torque iceTau annotation (
          Placement(visible = true, transformation(extent = {{-80, 12}, {-60, 32}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor iceW annotation (
          Placement(visible = true, transformation(origin = {10, 70}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor vhPow annotation (
          Placement(visible = true, transformation(origin = {93, -35}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
        Modelica.Mechanics.Translational.Components.Mass mass(v(fixed = true, start = 0, displayUnit = "km/h"), m = 1300) annotation (
          Placement(visible = true, transformation(origin = {65, -35}, extent = {{-11, -11}, {11, 11}}, rotation = 0)));
        Modelica.Mechanics.Translational.Sensors.SpeedSensor vhVel annotation (
          Placement(visible = true, transformation(origin = {70, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
          Placement(visible = true, transformation(extent = {{84, -6}, {100, 10}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
          Placement(visible = true, transformation(extent = {{56, -8}, {76, 12}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia ICE(J = 0.73, w(fixed = true, start = iceSetW.k, displayUnit = "rad/s")) annotation (
          Placement(visible = true, transformation(extent = {{-54, 12}, {-34, 32}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
          Placement(visible = true, transformation(origin = {10, 2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant vRef(k = 130 / 3.6) annotation (
          Placement(visible = true, transformation(origin = {-3, -55}, extent = {{-9, -9}, {9, 9}}, rotation = 180)));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, S = 2.2, Cx = 0.26, m = mass.m) annotation (
          Placement(visible = true, transformation(origin = {107, -62}, extent = {{-9, -9}, {9, 9}}, rotation = 90)));
        Modelica.Blocks.Math.Gain gain1(k = 10) annotation (
          Placement(transformation(extent = {{-42, 42}, {-62, 62}})));
      equation
        connect(dragForce.flange, vhPow.flange_b) annotation (
          Line(points = {{107, -53}, {108, -53}, {108, -54}, {110, -54}, {110, -34}, {102, -34}, {102, -35}}, color = {0, 127, 0}));
        connect(vRef.y, feedback1.u1) annotation (
          Line(points = {{-12.9, -55}, {-11.9, -55}, {-11.9, -56}, {-24, -56}}, color = {0, 0, 127}));
        connect(PSD.ring, mot.flange_a) annotation (
          Line(points = {{20, 2}, {28, 2}}));
        connect(PSD.carrier, icePow.flange_b) annotation (
          Line(points = {{-5.55112e-16, 6}, {-5.55112e-16, 22}, {-10, 22}}));
        connect(genPow.flange_b, PSD.sun) annotation (
          Line(points = {{-12, -8}, {-12, -8}, {0, -8}, {0, 2}}));
        connect(icePow.flange_a, ICE.flange_b) annotation (
          Line(points = {{-30, 22}, {-34, 22}}));
        connect(iceTau.flange, ICE.flange_a) annotation (
          Line(points = {{-60, 22}, {-54, 22}}));
        connect(idealGear.flange_a, mot.flange_b) annotation (
          Line(points = {{56, 2}, {48, 2}}));
        connect(wheel.flangeR, idealGear.flange_b) annotation (
          Line(points = {{84, 2}, {76, 2}}));
        connect(wheel.flangeT, propPow.flange_a) annotation (
          Line(points = {{100, 2}, {112, 2}, {112, -22}, {20, -22}, {20, -34}, {28, -34}}, color = {0, 127, 0}));
        connect(vhVel.v, feedback1.u2) annotation (
          Line(points = {{59, -60}, {11.5, -60}, {11.5, -36}, {-31.25, -36}, {-31.25, -48}, {-32, -48}}, color = {0, 0, 127}));
        connect(vhVel.flange, vhPow.flange_a) annotation (
          Line(points = {{80, -60}, {80, -35}, {84, -35}}, color = {0, 127, 0}));
        connect(propPow.flange_b, mass.flange_a) annotation (
          Line(points = {{48, -34}, {54, -34}, {54, -35}}, color = {0, 127, 0}));
        connect(vhPow.flange_a, mass.flange_b) annotation (
          Line(points = {{84, -35}, {76, -35}}, color = {0, 127, 0}));
        connect(feedback.u2, iceW.w) annotation (
          Line(points = {{-24, 60}, {-24, 70}, {-1, 70}}, color = {0, 0, 127}));
        connect(icePow.flange_b, iceW.flange) annotation (
          Line(points = {{-10, 22}, {40, 22}, {40, 70}, {20, 70}}));
        connect(feedback.u1, iceSetW.y) annotation (
          Line(points = {{-16, 52}, {-8, 52}, {-8, 40}, {7, 40}}, color = {0, 0, 127}));
        connect(genPow.flange_a, gen.flange_b) annotation (
          Line(points = {{-32, -8}, {-38, -8}}));
        connect(gen.flange_a, genTau.flange) annotation (
          Line(points = {{-58, -8}, {-62, -8}, {-62, -9}, {-64, -9}}));
        connect(limTgen.y, genTau.tau) annotation (
          Line(points = {{-86, -29}, {-90, -29}, {-90, -10}, {-86, -10}, {-86, -9}, {-83.8, -9}}, color = {0, 0, 127}));
        connect(limTgen.u, gain.y) annotation (
          Line(points = {{-86, -52}, {-86, -56}, {-75, -56}}, color = {0, 0, 127}));
        connect(feedback1.y, gain.u) annotation (
          Line(points = {{-41, -56}, {-52, -56}}, color = {0, 0, 127}));
        connect(feedback.y, gain1.u) annotation (
          Line(points = {{-33, 52}, {-40, 52}}, color = {0, 0, 127}));
        connect(gain1.y, iceTau.tau) annotation (
          Line(points = {{-63, 52}, {-74, 52}, {-92, 52}, {-92, 22}, {-82, 22}}, color = {0, 0, 127}));
        annotation (
          experiment(StopTime = 120, Interval = 0.5),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<h4>newInst OK</h4>
<h4>Modello di base per mostrare le prime funzionalit&agrave; di un sistema basato su PSD.</h4>
<p><br><u>Obiettivo finale</u>: simulazione di principio di Toyota Prius </p>
<p><u>Obiettivo di questa simulazione</u>: </p>
<p>Analizzare i punti di lavoro del PSD in un transitorio in cui il veicolo partendo da 0 accelera fino alla velocit&agrave; di 100 km/h, agendo sul gen; l&apos;ICE &egrave; mantenuto a velocit&agrave; costante da uno specifico controllo in retroazione. </p>
</html>"),conversion(noneFromVersion = ""),
          Icon(coordinateSystem(extent = {{-100, -80}, {120, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Diagram(coordinateSystem(extent = {{-100, -80}, {120, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(origin = {18.4202, 31}, lineColor = {28, 108, 200}, extent = {{31.5798, 45}, {91.5798, 25}}, textString = "Valori iniziali:
velocità massa
velocità ICE
          "), Text(origin = {19.4729, 6}, lineColor = {238, 46, 47}, extent = {{30.5271, 54}, {88.5271, 30}}, textString = "Ripetere con valore più realistico 
di limTgen: 60Nm
Poi con velocità max di 120 km/h")}));
      end PSBasic2;

      model EleBalanceSim "Bilanciamento elettrico con simulazione (v. Epicicloidale.docx)"
        import Modelica.Constants.*;
        parameter Real vMass = 1300;
        parameter Real rho = 78 / 30;
        parameter Real sigma = 1 / rho;
        //  Real Tm = sigma * gear.flange_a.tau * wGen.w / (wMot.w + sigma * wGen.w);
        Real Tm = gear.flange_a.tau * ((1 + sigma) * wIce.w - wMot.w) / ((1 + sigma) * wIce.w);
        Real negPmot = -Tm * wMot.w;
        Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = rho) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-6, 0})));
        Modelica.Mechanics.Rotational.Components.Inertia ice(J = 0.73, w(fixed = true, start = 300, displayUnit = "rad/s")) annotation (
          Placement(transformation(extent = {{44, 50}, {64, 70}})));
        Modelica.Mechanics.Rotational.Components.IdealGear gear(ratio = 3.905) annotation (
          Placement(transformation(extent = {{46, -10}, {66, 10}})));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
          Placement(transformation(extent = {{70, -8}, {86, 8}})));
        Modelica.Mechanics.Translational.Sensors.SpeedSensor carVel annotation (
          Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 180, origin = {105, -43})));
        Modelica.Mechanics.Translational.Components.Mass mass(m = vMass, v(fixed = true, displayUnit = "km/h", start = 1.0)) annotation (
          Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 0, origin = {121, 1})));
        Modelica.Mechanics.Translational.Sensors.PowerSensor pResis annotation (
          Placement(transformation(extent = {{-6, -6}, {6, 6}}, rotation = 270, origin = {132, -24})));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, m = vMass, S = 2.2, Cx = 0.26) annotation (
          Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 90, origin = {131, -49})));
        Modelica.Mechanics.Rotational.Sources.Torque tauIce annotation (
          Placement(transformation(extent = {{16, 50}, {36, 70}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor pGen annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-20, -28})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor pIce annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = 180, origin = {12, 36})));
        Modelica.Mechanics.Translational.Sensors.PowerSensor pProp annotation (
          Placement(transformation(extent = {{-7, -7}, {7, 7}}, rotation = 0, origin = {99, 1})));
        Modelica.Mechanics.Rotational.Components.Inertia gen(w(fixed = false, displayUnit = "rpm"), J = 0.1) annotation (
          Placement(transformation(extent = {{-46, -58}, {-26, -38}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wGen annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 0, origin = {-48, 0})));
        Modelica.Blocks.Math.Feedback fbIce annotation (
          Placement(transformation(extent = {{-46, 50}, {-26, 70}})));
        EHPTlib.SupportModels.MapBasedRelated.InertiaTq mot(J = 0.1) annotation (
          Placement(transformation(extent = {{12, -10}, {32, 10}})));
        Modelica.Mechanics.Rotational.Sources.Torque tauGen annotation (
          Placement(transformation(extent = {{-70, -58}, {-50, -38}})));
        Modelica.Blocks.Math.Gain gain(k = -50.0) annotation (
          Placement(transformation(extent = {{18, -76}, {-2, -56}})));
        Modelica.Blocks.Math.Feedback fbGen annotation (
          Placement(transformation(extent = {{50, -56}, {30, -76}})));
        Modelica.Blocks.Sources.Ramp ramp(height = 30, duration = 30) annotation (
          Placement(transformation(extent = {{84, -76}, {64, -56}})));
        Modelica.Blocks.Sources.RealExpression tauM(y = Tm) annotation (
          Placement(transformation(extent = {{50, -36}, {30, -16}})));
        Modelica.Blocks.Sources.Constant const(k = 300) annotation (
          Placement(transformation(extent = {{-72, 50}, {-52, 70}})));
        Modelica.Blocks.Math.Gain gain1(k = 100) annotation (
          Placement(transformation(extent = {{-18, 50}, {2, 70}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wIce annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = -90, origin = {-36, 26})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wMot annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {60, 20})));
      equation
        connect(wheel.flangeR, gear.flange_b) annotation (
          Line(points = {{70, 0}, {66, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(pResis.flange_a, mass.flange_b) annotation (
          Line(points = {{132, -18}, {132, 1}, {130, 1}}, color = {0, 127, 0}, smooth = Smooth.None));
        connect(carVel.flange, pResis.flange_a) annotation (
          Line(points = {{114, -43}, {114, -18}, {132, -18}}, color = {0, 127, 0}, smooth = Smooth.None));
        connect(dragForce.flange, pResis.flange_b) annotation (
          Line(points = {{131, -42}, {132, -42}, {132, -30}}, color = {0, 127, 0}, smooth = Smooth.None));
        connect(tauIce.flange, ice.flange_a) annotation (
          Line(points = {{36, 60}, {44, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(pGen.flange_b, PSD.sun) annotation (
          Line(points = {{-20, -18}, {-20, 0}, {-16, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(pIce.flange_a, ice.flange_b) annotation (
          Line(points = {{22, 36}, {78, 36}, {78, 60}, {64, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(PSD.carrier, pIce.flange_b) annotation (
          Line(points = {{-16, 4}, {-16, 36}, {2, 36}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(pProp.flange_a, wheel.flangeT) annotation (
          Line(points = {{92, 1}, {90, 1}, {90, 0}, {86, 0}}, color = {0, 127, 0}, smooth = Smooth.None));
        connect(pProp.flange_b, mass.flange_a) annotation (
          Line(points = {{106, 1}, {112, 1}}, color = {0, 127, 0}, smooth = Smooth.None));
        connect(pGen.flange_a, gen.flange_b) annotation (
          Line(points = {{-20, -38}, {-20, -48}, {-26, -48}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(wGen.flange, PSD.sun) annotation (
          Line(points = {{-38, 0}, {-16, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(gear.flange_a, mot.flange_b) annotation (
          Line(points = {{46, 0}, {32, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(PSD.ring, mot.flange_a) annotation (
          Line(points = {{4, 0}, {12, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(gen.flange_a, tauGen.flange) annotation (
          Line(points = {{-46, -48}, {-50, -48}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(fbGen.y, gain.u) annotation (
          Line(points = {{31, -66}, {20, -66}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(gain.y, tauGen.tau) annotation (
          Line(points = {{-3, -66}, {-78, -66}, {-78, -48}, {-72, -48}, {-72, -48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(fbGen.u2, carVel.v) annotation (
          Line(points = {{40, -58}, {40, -43}, {95.1, -43}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(fbGen.u1, ramp.y) annotation (
          Line(points = {{48, -66}, {63, -66}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(tauM.y, mot.tau) annotation (
          Line(points = {{29, -26}, {16.55, -26}, {16.55, -10}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(const.y, fbIce.u1) annotation (
          Line(points = {{-51, 60}, {-44, 60}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(wIce.flange, PSD.carrier) annotation (
          Line(points = {{-36, 16}, {-22, 16}, {-22, 4}, {-16, 4}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(wIce.w, fbIce.u2) annotation (
          Line(points = {{-36, 37}, {-36, 52}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(tauIce.tau, gain1.y) annotation (
          Line(points = {{14, 60}, {3, 60}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(gain1.u, fbIce.y) annotation (
          Line(points = {{-20, 60}, {-27, 60}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(wMot.flange, mot.flange_b) annotation (
          Line(points = {{50, 20}, {38, 20}, {38, 0}, {32, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        annotation (
          experiment(StopTime = 40, Interval = 0.1),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html><head></head><body><p></p><h4>newInst OK</h4><h4>Modello di base per mostrare le prime funzionalità di un sistema basato su PSD.</h4><p></p>
    <p><br><u>Obiettivo finale</u>: simulazione di principio di Toyota Prius</p>
    <p><u>Obiettivo di questa simulazione</u>: </p>
    <p>Mostrare il controllo in bilanciamento elettrico.</p>
    </body></html>"),
          conversion(noneFromVersion = ""),
          Diagram(coordinateSystem(extent = {{-80, -80}, {140, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics),
          Icon(coordinateSystem(extent = {{-80, -80}, {140, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})));
      end EleBalanceSim;

      model FreeBraking "Modello a due macchine elettriche ideali (pure inerzie)"
        import Modelica.Constants.*;
        parameter Real vMass = 1300;
        Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
          Placement(visible = true, transformation(extent = {{-30, 10}, {-10, 30}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
          Placement(visible = true, transformation(extent = {{-6, 12}, {10, 28}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia mot(w(fixed = false, displayUnit = "rpm"), J = 0.59) annotation (
          Placement(visible = true, transformation(extent = {{-56, 10}, {-36, 30}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wGen annotation (
          Placement(visible = true, transformation(origin = {-60, -14}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor Pprop annotation (
          Placement(visible = true, transformation(origin = {24, 20}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Mechanics.Translational.Components.Mass mass(m = vMass, v(fixed = true, start = 33.333333333333, displayUnit = "km/h")) annotation (
          Placement(visible = true, transformation(origin = {46, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Mechanics.Translational.Sensors.PowerSensor Presis annotation (
          Placement(visible = true, transformation(origin = {62.5, -9.5}, extent = {{-9.5, -9.5}, {9.5, 9.5}}, rotation = 270)));
        EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, m = vMass, S = 2.2, Cx = 0.26) annotation (
          Placement(visible = true, transformation(origin = {61.5, -36.5}, extent = {{-9.5, -9.5}, {9.5, 9.5}}, rotation = 90)));
        Modelica.Mechanics.Translational.Sensors.SpeedSensor Vvh annotation (
          Placement(visible = true, transformation(origin = {29, -17}, extent = {{-9, -9}, {9, 9}}, rotation = 180)));
      equation
        connect(Vvh.flange, Presis.flange_a) annotation (
          Line(points = {{38, -17}, {38, 0}, {62.5, 0}}, color = {0, 127, 0}));
        connect(dragForce.flange, Presis.flange_b) annotation (
          Line(points = {{61.5, -27}, {61.5, -19.5}, {62.5, -19.5}, {62.5, -19}}, color = {0, 127, 0}));
        connect(Presis.flange_a, mass.flange_b) annotation (
          Line(points = {{62.5, 0}, {62, 0}, {62, 20}, {56, 20}, {56, 20}, {56, 20}}, color = {0, 127, 0}));
        connect(dragForce.flange, Presis.flange_b) annotation (
          Line(points = {{61.5, -27}, {62.5, -27}, {62.5, -19}}, color = {0, 127, 0}));
        connect(Pprop.flange_b, mass.flange_a) annotation (
          Line(points = {{32, 20}, {36, 20}}, color = {0, 127, 0}));
        connect(Pprop.flange_a, wheel.flangeT) annotation (
          Line(points = {{16, 20}, {10, 20}}, color = {0, 127, 0}));
        connect(wGen.flange, mot.flange_a) annotation (
          Line(points = {{-60, -4}, {-60, 9}, {-60, 9}, {-60, 20}, {-58, 20}, {-58, 20}, {-56, 20}}));
        connect(idealGear.flange_a, mot.flange_b) annotation (
          Line(points = {{-30, 20}, {-36, 20}}));
        connect(wheel.flangeR, idealGear.flange_b) annotation (
          Line(points = {{-6, 20}, {-10, 20}}));
        annotation (
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html><head></head><body><p></p><h4>Modello di base per mostrare le prime funzionalità di un sistema basato su PSD.</h4><p></p>
    <p><br><u>Obiettivo finale</u>: simulazione di principio di Toyota Prius</p>
    <p><u>Obiettivo di questa simulazione</u>: </p>
    <p>funzionamento con frenata naturale (=a seguito delle sole resistenze al moto) del veicolo di riferimento.</p>
    </body></html>"),
          conversion(noneFromVersion = ""),
          Diagram(coordinateSystem(extent = {{-100, -60}, {100, 60}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Icon(coordinateSystem(extent = {{-100, -60}, {100, 60}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          experiment(StartTime = 0, StopTime = 300, Tolerance = 0.0001, Interval = 0.15));
      end FreeBraking;
    end BasicPT;
    model PSecu1 "Full Power Split Device power train using Map-Based components"
      import Modelica.Constants.*;
      extends Modelica.Icons.Example;
      parameter Modelica.Units.SI.AngularVelocity wIceStart=50;
      Modelica.Units.SI.Energy EbatDel "energy delivered by the battery";
      Modelica.Units.SI.Energy EgenDelM
        "energy delivered by gen trough mechanical flange";
      Modelica.Units.SI.Energy Eroad
        "mechanical energy absorbed by roas (friction & air)";
      Modelica.Units.SI.Energy EiceDel "mechanical energy delivered by ice";
      Modelica.Units.SI.Energy Emot;
      Modelica.Units.SI.Energy Emass;
      Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-50, 52})));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
        Placement(transformation(extent = {{2, 42}, {22, 62}})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor carVel annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {78, -12})));
      Modelica.Mechanics.Translational.Components.Mass mass(v(fixed = true, start = 0), m = 1300) annotation (
        Placement(transformation(extent = {{54, 42}, {74, 62}})));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, S = 2.2, Cx = 0.26, m = mass.m) annotation (
        Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 90, origin = {89, 29})));
      EHPTlib.MapBased.IceConnP ice annotation (
        Placement(transformation(extent = {{-98, 46}, {-78, 66}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1Conn bat(ECellMin = 0.9, ECellMax = 1.45, R0Cell = 0.0003, ns = 168, QCellNom = 2 * 6.5 * 3600.0, SOCInit = 0.6, ICellMax = 1e5, iCellEfficiency = 15 * 6.5) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-16, 0})));
      EHPTlib.SupportModels.ConnectorRelated.Conn d annotation (
        Placement(visible = true, transformation(extent = {{2, -40}, {28, -16}}, rotation = 0), iconTransformation(extent = {{4, -52}, {30, -28}}, rotation = 0)));
      EHPTlib.MapBased.ECUs.Ecu1 ECU(genLoopGain = 1.0) annotation (
        Placement(visible = true, transformation(origin = {-10, -41}, extent = {{-10, -9}, {10, 9}}, rotation = 0)));
      EHPTlib.MapBased.TwoFlangeConn mot(effTableName = "motEffTable", mapsFileName = "PSDmaps.txt", mapsOnFile = true) annotation (
        Placement(visible = true, transformation(extent = {{-28, 62}, {-8, 42}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(origin = {38, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(origin = {10, 26}, extent = {{10, 10}, {-10, -10}}, rotation = 270)));
      EHPTlib.MapBased.OneFlangeConn gen annotation (
        Placement(visible = true, transformation(extent = {{-38, 10}, {-58, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", k = 1, yMax = 1.8) annotation (
        Placement(visible = true, transformation(extent = {{-60, -50}, {-40, -30}}, rotation = 0)));
    equation
      connect(ECU.tauRef, driver.tauRef) annotation (
        Line(points = {{-22, -41}, {-29, -41}, {-29, -40}, {-39, -40}}, color = {0, 0, 127}));
      connect(carVel.v, driver.V) annotation (
        Line(points = {{78, -23}, {78, -58}, {-50, -58}, {-50, -51.2}}, color = {0, 0, 127}));
      connect(mot.conn1, ECU.conn1) annotation (
        Line(points = {{-27.2, 59.8}, {-27.2, 72}, {50, 72}, {50, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(gen.pin_p, bat.p) annotation (
        Line(points = {{-38, 24}, {-24, 24}, {-24, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(gen.pin_n, bat.n) annotation (
        Line(points = {{-38, 16}, {-8.5, 16}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(gen.flange_a, PSD.sun) annotation (
        Line(points = {{-58, 20}, {-70, 20}, {-70, 52}, {-60, 52}}));
      connect(gen.conn, ECU.conn1) annotation (
        Line(points = {{-58, 12.2}, {-58, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ground.p, bat.n) annotation (
        Line(points = {{0, 26}, {-8.5, 26}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(wheel.flangeT, mass.flange_a) annotation (
        Line(points = {{48, 52}, {54, 52}}, color = {0, 127, 0}));
      connect(wheel.flangeR, idealGear.flange_b) annotation (
        Line(points = {{28, 52}, {22, 52}}));
      connect(PSD.ring, mot.flange_a) annotation (
        Line(points = {{-40, 52}, {-34, 52}, {-28, 52}}));
      connect(idealGear.flange_a, mot.flange_b) annotation (
        Line(points = {{2, 52}, {-4, 52}, {-4, 52.2}, {-8, 52.2}}));
      connect(mot.pin_p, bat.p) annotation (
        Line(points = {{-22, 42.2}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(mot.pin_n, bat.n) annotation (
        Line(points = {{-14, 42}, {-14, 10.1}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(bat.conn, ECU.conn1) annotation (
        Line(points = {{-15.75, -10}, {-16, -10}, {-16, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ice.conn, ECU.conn1) annotation (
        Line(points = {{-88, 45.8}, {-88, 45.8}, {-88, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ECU.conn1, d) annotation (
        Line(points = {{-10, -32.18}, {-10, -28}, {15, -28}}, color = {255, 204, 51}, thickness = 0.5));
      der(EbatDel) = (bat.p.v - bat.n.v) * bat.n.i;
      der(EgenDelM) = gen.pin_p.i * (gen.pin_p.v - gen.pin_n.v) + gen.flange_a.tau * der(gen.flange_a.phi);
      der(Eroad) = dragForce.flange.f * der(dragForce.flange.s);
      der(EiceDel) = -ice.flange_a.tau * der(ice.flange_a.phi);
      der(Emot) = mot.flange_a.tau * der(mot.flange_a.phi) + mot.flange_b.tau * der(mot.flange_b.phi);
      Emass = 0.5 * mass.m * der(mass.flange_a.s) ^ 2;
      connect(PSD.carrier, ice.flange_a) annotation (
        Line(points = {{-60, 56}, {-70, 56}, {-70, 56}, {-78, 56}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(dragForce.flange, mass.flange_b) annotation (
        Line(points = {{89, 38}, {90, 38}, {90, 52}, {74, 52}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(carVel.flange, mass.flange_b) annotation (
        Line(points = {{78, -2}, {78, 52}, {74, 52}}, color = {0, 127, 0}, smooth = Smooth.None));
      annotation (
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p>This model simulates a PSD based power train with a simple control logic, in its ECU:</p>
<p>It tries to make the ICE deliver the average load power, at its optimal speed.</p>
<p>This has two main inconveniences:</p>
<ul>
<li>the battery SOC is not controlled and tends to drift</li>
<li>in urban environments the power is too low to allow efficient drive without shutting off the engine.</li>
</ul>
<p>These inconveniences are addressed in subsequent models PSEcu2 and PSecu3 (see their infos).</p>
</html>"),
        Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 2.8));
    end PSecu1;

    model PSecu2 "Full Power Split Device power train using Map-Based components"
      import Modelica.Constants.*;
      extends Modelica.Icons.Example;
      parameter Modelica.Units.SI.AngularVelocity wIceStart=50;
      Modelica.Units.SI.Energy EbatDel "energy delivered by the battery";
      Modelica.Units.SI.Energy EgenDelM
        "energy delivered by gen trough mechanical flange";
      Modelica.Units.SI.Energy Eroad
        "mechanical energy absorbed by roas (friction & air)";
      Modelica.Units.SI.Energy EiceDel "mechanical energy delivered by ice";
      Modelica.Units.SI.Energy Emot;
      Modelica.Units.SI.Energy Emass;
      Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-50, 52})));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
        Placement(transformation(extent = {{2, 42}, {22, 62}})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor carVel annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {78, -12})));
      Modelica.Mechanics.Translational.Components.Mass mass(v(fixed = true, start = 0), m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{54, 42}, {74, 62}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, S = 2.2, Cx = 0.26, m = mass.m) annotation (
        Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 90, origin = {89, 29})));
      EHPTlib.MapBased.IceConnP ice(wIceStart = wIceStart, mapsFileName = "PSDmaps.txt") annotation (
        Placement(transformation(extent = {{-98, 46}, {-78, 66}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1Conn bat(ECellMin = 0.9, ECellMax = 1.45, R0Cell = 0.0003, ns = 168, QCellNom = 2 * 6.5 * 3600.0, SOCInit = 0.6, ICellMax = 1e5, iCellEfficiency = 15 * 6.5) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-16, 0})));
      EHPTlib.SupportModels.ConnectorRelated.Conn d annotation (
        Placement(visible = true, transformation(extent = {{2, -40}, {28, -16}}, rotation = 0), iconTransformation(extent = {{4, -52}, {30, -28}}, rotation = 0)));
      EHPTlib.MapBased.ECUs.Ecu2 ECU(socLoopGain = 1e5, genLoopGain = 1.0) annotation (
        Placement(visible = true, transformation(origin = {-10, -41}, extent = {{-10, -9}, {10, 9}}, rotation = 0)));
      EHPTlib.MapBased.TwoFlangeConn mot annotation (
        Placement(visible = true, transformation(extent = {{-28, 62}, {-8, 42}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(origin = {38, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(origin = {10, 26}, extent = {{10, 10}, {-10, -10}}, rotation = 270)));
      EHPTlib.MapBased.OneFlangeConn gen(mapsOnFile = true, mapsFileName = "PSDmaps.txt", effTableName = "genEffTable") annotation (
        Placement(visible = true, transformation(extent = {{-38, 10}, {-58, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", k = 1, yMax = 1.8) annotation (
        Placement(visible = true, transformation(extent = {{-60, -50}, {-40, -30}}, rotation = 0)));
    equation
      connect(carVel.flange, mass.flange_b) annotation (
        Line(points = {{78, -2}, {78, 52}, {74, 52}}, color = {0, 127, 0}));
      connect(dragForce.flange, mass.flange_b) annotation (
        Line(points = {{89, 38}, {90, 38}, {90, 52}, {74, 52}}, color = {0, 127, 0}));
      connect(wheel.flangeT, mass.flange_a) annotation (
        Line(points = {{48, 52}, {54, 52}}, color = {0, 127, 0}));
      connect(ECU.tauReference, driver.tauRef) annotation (
        Line(points = {{-22, -41}, {-29, -41}, {-29, -40}, {-39, -40}}, color = {0, 0, 127}));
      connect(carVel.v, driver.V) annotation (
        Line(points = {{78, -23}, {78, -58}, {-50, -58}, {-50, -51.2}}, color = {0, 0, 127}));
      connect(mot.conn1, ECU.conn1) annotation (
        Line(points = {{-27.2, 59.8}, {-27.2, 72}, {50, 72}, {50, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(gen.pin_n, bat.n) annotation (
        Line(points = {{-38, 16}, {-8.5, 16}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(gen.flange_a, PSD.sun) annotation (
        Line(points = {{-58, 20}, {-70, 20}, {-70, 52}, {-60, 52}}));
      connect(gen.conn, ECU.conn1) annotation (
        Line(points = {{-58, 12.2}, {-58, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ground.p, bat.n) annotation (
        Line(points = {{0, 26}, {-8.5, 26}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(wheel.flangeR, idealGear.flange_b) annotation (
        Line(points = {{28, 52}, {22, 52}}));
      connect(PSD.ring, mot.flange_a) annotation (
        Line(points = {{-40, 52}, {-34, 52}, {-28, 52}}));
      connect(idealGear.flange_a, mot.flange_b) annotation (
        Line(points = {{2, 52}, {-4, 52}, {-4, 52.2}, {-8, 52.2}}));
      connect(mot.pin_p, bat.p) annotation (
        Line(points = {{-22, 42.2}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(mot.pin_n, bat.n) annotation (
        Line(points = {{-14, 42}, {-14, 10.1}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(bat.conn, ECU.conn1) annotation (
        Line(points = {{-15.75, -10}, {-16, -10}, {-16, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ice.conn, ECU.conn1) annotation (
        Line(points = {{-88, 45.8}, {-88, 45.8}, {-88, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ECU.conn1, d) annotation (
        Line(points = {{-10, -32.18}, {-10, -28}, {15, -28}}, color = {255, 204, 51}, thickness = 0.5));
      der(EbatDel) = (bat.p.v - bat.n.v) * bat.n.i;
      der(EgenDelM) = gen.pin_p.i * (gen.pin_p.v - gen.pin_n.v) + gen.flange_a.tau * der(gen.flange_a.phi);
      der(Eroad) = dragForce.flange.f * der(dragForce.flange.s);
      der(EiceDel) = -ice.flange_a.tau * der(ice.flange_a.phi);
      der(Emot) = mot.flange_a.tau * der(mot.flange_a.phi) + mot.flange_b.tau * der(mot.flange_b.phi);
      Emass = 0.5 * mass.m * der(mass.flange_a.s) ^ 2;
      connect(PSD.carrier, ice.flange_a) annotation (
        Line(points = {{-60, 56}, {-78, 56}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(gen.pin_p, bat.p) annotation (
        Line(points = {{-38, 24}, {-38, 34}, {-22, 34}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      annotation (
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p>This model simulates a PSD based power train with a simple control logic, in its ECU:</p>
<p>it tries to make the ICE deliver the average load power, at its optimal speed and with a loop in the ECU that compensates SOC drift (improvement of Ecu2 over Ecu1, thus of PSecu2 over PSecu1).</p>
</html>"),
        Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 2.8));
    end PSecu2;

    model PSecu3 "Full Power Split Device power train using Map-Based components"
      import Modelica.Constants.*;
      extends Modelica.Icons.Example;
      parameter Modelica.Units.SI.AngularVelocity wIceStart=50;
      parameter Real factorDebug = 100;
      // rad/s
      Modelica.Units.SI.Energy EbatDel "energy delivered by the battery";
      Modelica.Units.SI.Energy EgenDelM
        "energy delivered by gen trough mechanical flange";
      Modelica.Units.SI.Energy Eroad
        "mechanical energy absorbed by roas (friction & air)";
      Modelica.Units.SI.Energy EiceDel "mechanical energy delivered by ice";
      Modelica.Units.SI.Energy Emot;
      Modelica.Units.SI.Energy Emass;
      Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-50, 52})));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
        Placement(transformation(extent = {{2, 42}, {22, 62}})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor carVel annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {78, -12})));
      Modelica.Mechanics.Translational.Components.Mass mass(m = 1300, v(fixed = true, start = 0)) annotation (
        Placement(transformation(extent = {{54, 42}, {74, 62}})));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(Cx = 0.26, S = 2.2, fc = 0.014, m = mass.m, rho = 1.226) annotation (
        Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 90, origin = {89, 29})));
      EHPTlib.MapBased.IceConnPOO ice(mapsFileName = "PSDmaps.txt", wIceStart = wIceStart) annotation (
        Placement(transformation(extent = {{-98, 46}, {-78, 66}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1Conn bat(ECellMin = 0.9, ECellMax = 1.45, R0Cell = 0.0003, ns = 168, QCellNom = 2 * 6.5 * 3600.0, SOCInit = 0.6, ICellMax = 1e5, iCellEfficiency = 15 * 6.5) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-16, 0})));
      EHPTlib.SupportModels.ConnectorRelated.Conn d annotation (
        Placement(visible = true, transformation(extent = {{2, -40}, {28, -16}}, rotation = 0), iconTransformation(extent = {{4, -52}, {30, -28}}, rotation = 0)));
      EHPTlib.MapBased.ECUs.Ecu3 ECU(genLoopGain = 1.0, socRef = 0.65) annotation (
        Placement(visible = true, transformation(origin = {-10, -41}, extent = {{-10, -9}, {10, 9}}, rotation = 0)));
      EHPTlib.MapBased.TwoFlangeConn mot annotation (
        Placement(visible = true, transformation(extent = {{-28, 62}, {-8, 42}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(origin = {38, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      EHPTlib.MapBased.OneFlangeConn gen annotation (
        Placement(visible = true, transformation(extent = {{-38, 10}, {-58, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(CycleFileName = "NEDC.txt", k = 1, yMax = 1.8) annotation (
        Placement(visible = true, transformation(extent = {{-60, -50}, {-40, -30}}, rotation = 0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(origin = {12, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
    equation
      connect(ground.p, bat.n) annotation (
        Line(points = {{12, 20}, {-8, 20}, {-8, 10}, {-8, 10.1}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(ECU.tauReference, driver.tauRef) annotation (
        Line(points = {{-22, -41}, {-29, -41}, {-29, -40}, {-39, -40}}, color = {0, 0, 127}));
      connect(carVel.v, driver.V) annotation (
        Line(points = {{78, -23}, {78, -58}, {-50, -58}, {-50, -51.2}}, color = {0, 0, 127}));
      connect(mot.conn1, ECU.conn) annotation (
        Line(points = {{-27.2, 59.8}, {-27.2, 72}, {50, 72}, {50, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(gen.pin_p, bat.p) annotation (
        Line(points = {{-38, 24}, {-22, 24}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(gen.pin_n, bat.n) annotation (
        Line(points = {{-38, 16}, {-8.5, 16}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(gen.flange_a, PSD.sun) annotation (
        Line(points = {{-58, 20}, {-70, 20}, {-70, 52}, {-60, 52}}));
      connect(gen.conn, ECU.conn) annotation (
        Line(points = {{-58, 12.2}, {-58, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(wheel.flangeT, mass.flange_a) annotation (
        Line(points = {{48, 52}, {54, 52}}, color = {0, 127, 0}));
      connect(wheel.flangeR, idealGear.flange_b) annotation (
        Line(points = {{28, 52}, {22, 52}}));
      connect(PSD.ring, mot.flange_a) annotation (
        Line(points = {{-40, 52}, {-34, 52}, {-28, 52}}));
      connect(idealGear.flange_a, mot.flange_b) annotation (
        Line(points = {{2, 52}, {-4, 52}, {-4, 52.2}, {-8, 52.2}}));
      connect(mot.pin_p, bat.p) annotation (
        Line(points = {{-22, 42.2}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(mot.pin_n, bat.n) annotation (
        Line(points = {{-14, 42}, {-14, 10.1}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(bat.conn, ECU.conn) annotation (
        Line(points = {{-15.75, -10}, {-16, -10}, {-16, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ice.conn, ECU.conn) annotation (
        Line(points = {{-88, 46.2}, {-88, 46.2}, {-88, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ECU.conn, d) annotation (
        Line(points = {{-10, -32.18}, {-10, -28}, {15, -28}}, color = {255, 204, 51}, thickness = 0.5));
      der(EbatDel) = (bat.p.v - bat.n.v) * bat.n.i;
      der(EgenDelM) = gen.pin_p.i * (gen.pin_p.v - gen.pin_n.v) + gen.flange_a.tau * der(gen.flange_a.phi);
      der(Eroad) = dragForce.flange.f * der(dragForce.flange.s);
      der(EiceDel) = -ice.flange_a.tau * der(ice.flange_a.phi);
      der(Emot) = mot.flange_a.tau * der(mot.flange_a.phi) + mot.flange_b.tau * der(mot.flange_b.phi);
      Emass = 0.5 * mass.m * der(mass.flange_a.s) ^ 2;
      connect(PSD.carrier, ice.flange_a) annotation (
        Line(points = {{-60, 56}, {-78, 56}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(dragForce.flange, mass.flange_b) annotation (
        Line(points = {{89, 38}, {90, 38}, {90, 52}, {74, 52}}, color = {0, 127, 0}, smooth = Smooth.None));
      connect(carVel.flange, mass.flange_b) annotation (
        Line(points = {{78, -2}, {78, 52}, {74, 52}}, color = {0, 127, 0}, smooth = Smooth.None));
      annotation (
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html><head></head><body><p>This model simulates a PSD based power train with a simple control logic, in its ECU:</p>
<p>it tries to make the ICE deliver the average load power, at its optimal speed and:</p>
<ol>
<li>has a loop in the ECU that compensates SOC drift (improvement Ecu1, thus over PSecu1)</li>
<li>has an ysteresis control in the ECU that implements ON/OFF strategy to avoid too low powers (and correspondingly high consumption) in urban environments (improvement of Ecu3 over Ecu1 and Ecu2, thus of PSecu3 over PSecu1 and PSecu2)</li>
</ol>
</body></html>"),
        Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 2.8));
    end PSecu3;

    model PSecu2PA "Full Power Split Device power train using Map-Based components"
      import Modelica.Constants.*;
      extends Modelica.Icons.Example;
      parameter Modelica.Units.SI.AngularVelocity wIceStart=50;
      Modelica.Units.SI.Energy EbatDel "energy delivered by the battery";
      Modelica.Units.SI.Energy EgenDelM
        "energy delivered by gen trough mechanical flange";
      Modelica.Units.SI.Energy Eroad
        "mechanical energy absorbed by roas (friction & air)";
      Modelica.Units.SI.Energy EiceDel "mechanical energy delivered by ice";
      Modelica.Units.SI.Energy Emot;
      Modelica.Units.SI.Energy Emass;
      Modelica.Mechanics.Rotational.Components.IdealPlanetary PSD(ratio = 78 / 30) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-50, 52})));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = 3.905) annotation (
        Placement(transformation(extent = {{2, 42}, {22, 62}})));
      Modelica.Mechanics.Translational.Sensors.SpeedSensor carVel annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {78, -12})));
      Modelica.Mechanics.Translational.Components.Mass mass(v(fixed = true, start = 0), m = 1300) annotation (
        Placement(visible = true, transformation(extent = {{54, 42}, {74, 62}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.DragForce dragForce(fc = 0.014, rho = 1.226, S = 2.2, Cx = 0.26, m = mass.m) annotation (
        Placement(transformation(extent = {{-9, -9}, {9, 9}}, rotation = 90, origin = {89, 29})));
      EHPTlib.MapBased.IceConnP ice(wIceStart = wIceStart, mapsFileName = "PSDmaps.txt") annotation (
        Placement(transformation(extent = {{-98, 46}, {-78, 66}})));
      EHPTlib.SupportModels.Miscellaneous.Batt1Conn bat(ECellMin = 0.9, ECellMax = 1.45, R0Cell = 0.0003, SOCInit = 0.6, ICellMax = 1e5, iCellEfficiency = 15 * 6.5, ns = 100, QCellNom = 2 * 3600.0) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-16, 0})));
      EHPTlib.SupportModels.ConnectorRelated.Conn d annotation (
        Placement(visible = true, transformation(extent = {{2, -40}, {28, -16}}, rotation = 0), iconTransformation(extent = {{4, -52}, {30, -28}}, rotation = 0)));
      EHPTlib.MapBased.ECUs.Ecu2 ECU(genLoopGain = 1.0, socLoopGain = 2e4, powFiltT = 10) annotation (
        Placement(visible = true, transformation(origin = {-10, -41}, extent = {{-10, -9}, {10, 9}}, rotation = 0)));
      EHPTlib.MapBased.TwoFlangeConn mot annotation (
        Placement(visible = true, transformation(extent = {{-28, 62}, {-8, 42}}, rotation = 0)));
      Modelica.Mechanics.Rotational.Components.IdealRollingWheel wheel(radius = 0.31) annotation (
        Placement(visible = true, transformation(origin = {38, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Electrical.Analog.Basic.Ground ground annotation (
        Placement(visible = true, transformation(origin = {10, 26}, extent = {{10, 10}, {-10, -10}}, rotation = 270)));
      EHPTlib.MapBased.OneFlangeConn gen annotation (
        Placement(visible = true, transformation(extent = {{-38, 10}, {-58, 30}}, rotation = 0)));
      EHPTlib.SupportModels.Miscellaneous.PropDriver driver(yMax = 1.8, CycleFileName = "nedc.txt", k = 1) annotation (
        Placement(visible = true, transformation(extent = {{-60, -50}, {-40, -30}}, rotation = 0)));
    equation
      connect(carVel.flange, mass.flange_b) annotation (
        Line(points = {{78, -2}, {78, 52}, {74, 52}}, color = {0, 127, 0}));
      connect(dragForce.flange, mass.flange_b) annotation (
        Line(points = {{89, 38}, {90, 38}, {90, 52}, {74, 52}}, color = {0, 127, 0}));
      connect(wheel.flangeT, mass.flange_a) annotation (
        Line(points = {{48, 52}, {54, 52}}, color = {0, 127, 0}));
      connect(ECU.tauReference, driver.tauRef) annotation (
        Line(points = {{-22, -41}, {-29, -41}, {-29, -40}, {-39, -40}}, color = {0, 0, 127}));
      connect(carVel.v, driver.V) annotation (
        Line(points = {{78, -23}, {78, -58}, {-50, -58}, {-50, -51.2}}, color = {0, 0, 127}));
      connect(mot.conn1, ECU.conn1) annotation (
        Line(points = {{-27.2, 59.8}, {-27.2, 72}, {50, 72}, {50, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(gen.pin_n, bat.n) annotation (
        Line(points = {{-38, 16}, {-8.5, 16}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(gen.flange_a, PSD.sun) annotation (
        Line(points = {{-58, 20}, {-58, 20}, {-70, 20}, {-70, 52}, {-60, 52}}));
      connect(gen.conn, ECU.conn1) annotation (
        Line(points = {{-58, 12.2}, {-58, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ground.p, bat.n) annotation (
        Line(points = {{0, 26}, {-8.5, 26}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(wheel.flangeR, idealGear.flange_b) annotation (
        Line(points = {{28, 52}, {22, 52}}));
      connect(PSD.ring, mot.flange_a) annotation (
        Line(points = {{-40, 52}, {-34, 52}, {-28, 52}}));
      connect(idealGear.flange_a, mot.flange_b) annotation (
        Line(points = {{2, 52}, {-4, 52}, {-4, 52.2}, {-8, 52.2}}));
      connect(mot.pin_p, bat.p) annotation (
        Line(points = {{-22, 42.2}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      connect(mot.pin_n, bat.n) annotation (
        Line(points = {{-14, 42}, {-14, 10.1}, {-8.5, 10.1}}, color = {0, 0, 255}));
      connect(bat.conn, ECU.conn1) annotation (
        Line(points = {{-15.75, -10}, {-16, -10}, {-16, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ice.conn, ECU.conn1) annotation (
        Line(points = {{-88, 45.8}, {-88, 45.8}, {-88, -20}, {-10, -20}, {-10, -32.18}}, color = {255, 204, 51}, thickness = 0.5));
      connect(ECU.conn1, d) annotation (
        Line(points = {{-10, -32.18}, {-10, -28}, {15, -28}}, color = {255, 204, 51}, thickness = 0.5));
      der(EbatDel) = (bat.p.v - bat.n.v) * bat.n.i;
      der(EgenDelM) = gen.pin_p.i * (gen.pin_p.v - gen.pin_n.v) + gen.flange_a.tau * der(gen.flange_a.phi);
      der(Eroad) = dragForce.flange.f * der(dragForce.flange.s);
      der(EiceDel) = -ice.flange_a.tau * der(ice.flange_a.phi);
      der(Emot) = mot.flange_a.tau * der(mot.flange_a.phi) + mot.flange_b.tau * der(mot.flange_b.phi);
      Emass = 0.5 * mass.m * der(mass.flange_a.s) ^ 2;
      connect(PSD.carrier, ice.flange_a) annotation (
        Line(points = {{-60, 56}, {-78, 56}}, color = {0, 0, 0}, smooth = Smooth.None));
      connect(gen.pin_p, bat.p) annotation (
        Line(points = {{-38, 24}, {-38, 34}, {-22, 34}, {-22, 10}, {-23.75, 10}}, color = {0, 0, 255}));
      annotation (
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p>Like PSecu2, but solves the Proposed Activity that requires a very small battery and near-CVT (continuosuly-variable Transmission) operation. </p>
</html>"),
        Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        experiment(StartTime = 0, StopTime = 1400, Tolerance = 0.0001, Interval = 2.8));
    end PSecu2PA;
  end PSD;

  package VehicleData
    record Bus
      parameter Real m = 16000;
      parameter Real ratio = 6;
      parameter Real radius = 0.5715;
      parameter Real J = 5;
      //Costante H=5s
      parameter Real Cx = 0.65;
      parameter Real S = 6;
      parameter Real fc = 0.013;
      parameter Real rho = 1.226;
      parameter Real kContr = 1000;
      annotation (
        Icon(coordinateSystem(preserveAspectRatio = false), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {162, 29, 33}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-94, 22}, {96, -16}}, lineColor = {162, 29, 33}, textString = "Bus"), Text(extent = {{-100, -104}, {100, -140}}, lineColor = {0, 0, 255}, textString = "%name")}),
        Diagram(coordinateSystem(preserveAspectRatio = false)));
    end Bus;

    record Car
      parameter Real m = 1300;
      parameter Real ratio = 3.905;
      parameter Real radius = 0.31;
      parameter Real J = 1.5;
      parameter Real Cx = 0.26;
      parameter Real S = 2.2;
      parameter Real fc = 0.014;
      parameter Real rho = 1.226;
      parameter Real kContr = 100;
      /* To compujte J A starting time Tstart=2s was used, Pn=50kW, 
      Wbase= the one corrisponding to 36 km/h, so 252 rad/s*/
      annotation (
        Icon(coordinateSystem(preserveAspectRatio = false), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {162, 29, 33}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-94, 22}, {96, -16}}, lineColor = {162, 29, 33}, textString = "Car"), Text(extent = {{-100, -104}, {100, -140}}, lineColor = {0, 0, 255}, textString = "%name")}),
        Diagram(coordinateSystem(preserveAspectRatio = false)));
    end Car;
  end VehicleData;
  annotation (
    uses(Modelica(version="4.0.0"),EHPTlib(version="2.0.0")));
end EHPTexamples;
