package EHPTlib "Electric and Hybrid Power train library Rev Sept 2021"
  package SupportModels "Useful addtional models"
    extends Modelica.Icons.Package;
    // extends EHPowerTrain.Icons.SupportIcon;

    package MapBasedRelated
      model InertiaTq "Inertia with added torque"
        import SI = Modelica.SIunits;
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a "Left flange of shaft" annotation (
          Placement(transformation(extent = {{-110, -10}, {-90, 10}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_b "Right flange of shaft" annotation (
          Placement(transformation(extent = {{90, -10}, {110, 10}}, rotation = 0)));
        parameter SI.Inertia J(min = 0, start = 1) "Moment of inertia";
        parameter StateSelect stateSelect = StateSelect.default "Priority to use phi and w as states" annotation (
          HideResult = true,
          Dialog(tab = "Advanced"));
        SI.Angle phi(stateSelect = stateSelect) "Absolute rotation angle of component" annotation (
          Dialog(group = "Initialization", showStartAttribute = true));
        SI.AngularVelocity w(stateSelect = stateSelect) "Absolute angular velocity of component (= der(phi))" annotation (
          Dialog(group = "Initialization", showStartAttribute = true));
        SI.AngularAcceleration a "Absolute angular acceleration of component (= der(w))" annotation (
          Dialog(group = "Initialization", showStartAttribute = true));
        Modelica.Blocks.Interfaces.RealInput tau annotation (
          Placement(transformation(extent = {{-20.5, -20}, {20.5, 20}}, rotation = 90, origin = {-54.5, -100})));
      equation
        phi = flange_a.phi;
        phi = flange_b.phi;
        w = der(phi);
        a = der(w);
        J * a = flange_a.tau + flange_b.tau + tau;
        annotation (
          Documentation(info = "<html>
    <p>
    Rotational component with <b>inertia</b> and two rigidly connected flanges.
    </p>

    </HTML>
    "),   Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}, grid = {2, 2}), graphics = {Rectangle(extent = {{-100, 10}, {-50, -10}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {192, 192, 192}), Rectangle(extent = {{50, 10}, {100, -10}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {192, 192, 192}), Line(points = {{-80, -25}, {-60, -25}}, color = {0, 0, 0}), Line(points = {{60, -25}, {80, -25}}, color = {0, 0, 0}), Line(points = {{-70, -25}, {-70, -70}}, color = {0, 0, 0}), Line(points = {{70, -25}, {70, -70}}, color = {0, 0, 0}), Line(points = {{-80, 25}, {-60, 25}}, color = {0, 0, 0}), Line(points = {{60, 25}, {80, 25}}, color = {0, 0, 0}), Line(points = {{-70, 45}, {-70, 25}}, color = {0, 0, 0}), Line(points = {{70, 45}, {70, 25}}, color = {0, 0, 0}), Line(points = {{-70, -70}, {70, -70}}, color = {0, 0, 0}), Rectangle(extent = {{-50, 50}, {50, -50}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {192, 192, 192}), Text(extent = {{-150, 100}, {150, 60}}, textString = "%name", lineColor = {0, 0, 255}), Text(extent = {{-150, -80}, {150, -120}}, lineColor = {0, 0, 0}, textString = "J=%J")}),
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}, grid = {2, 2}), graphics));
      end InertiaTq;

      block EfficiencyT "Determines the electric power from the mechanical considering efficiency map"
        parameter Boolean mapsOnFile = false;
        parameter Modelica.SIunits.Torque tauMax(start = 400) "Maximum machine torque";
        parameter Modelica.SIunits.Power powMax(start = 22000) "Maximum drive power";
        parameter Modelica.SIunits.AngularVelocity wMax(start = 650) "Maximum machine speed";
        parameter String mapsFileName = "NoName" "File where matrix is stored" annotation (
          Dialog(enable = mapsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String effTableName = "noName" "name of the on-file efficiency matrix" annotation (
          Dialog(enable = mapsOnFile));
        parameter Real effTable[:, :] = [0.00, 0.00, 0.25, 0.50, 0.75, 1.00; 0.00, 0.75, 0.80, 0.81, 0.82, 0.83; 0.25, 0.76, 0.81, 0.82, 0.83, 0.84; 0.50, 0.77, 0.82, 0.83, 0.84, 0.85; 0.75, 0.78, 0.83, 0.84, 0.85, 0.87; 1.00, 0.80, 0.84, 0.85, 0.86, 0.88] annotation (
          Dialog(enable = not mapsOnFile));
        //the name is passed because a file can contain efficiency tables for
        //different submodels, e.g. genEfficiency for generator and motEfficiency for motor.
        Modelica.Blocks.Tables.CombiTable2D effTable_(tableOnFile = mapsOnFile, smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments, fileName = mapsFileName, tableName = effTableName, table = effTable) "normalised efficiency" annotation (
          Placement(transformation(extent = {{-14, -14}, {14, 14}}, rotation = 0, origin = {18, -18})));
        Modelica.Blocks.Interfaces.RealInput w annotation (
          Placement(transformation(extent = {{-140, -60}, {-100, -20}}), iconTransformation(extent = {{-140, -60}, {-100, -20}})));
        Modelica.Blocks.Interfaces.RealInput tau annotation (
          Placement(transformation(extent = {{-140, 20}, {-100, 60}}), iconTransformation(extent = {{-140, 20}, {-100, 60}})));
        Modelica.Blocks.Interfaces.RealOutput elePow annotation (
          Placement(transformation(extent = {{96, -10}, {116, 10}})));
        Modelica.Blocks.Math.Abs abs1 annotation (
          Placement(transformation(extent = {{-76, -50}, {-56, -30}})));
        Modelica.Blocks.Math.Abs abs2 annotation (
          Placement(transformation(extent = {{-80, 40}, {-60, 60}})));
        Modelica.Blocks.Math.Gain normalizeTau(k = 1 / tauMax) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-36, 50})));
        SupportModels.MapBasedRelated.Pel applyEta annotation (
          Placement(transformation(extent = {{60, -10}, {84, 12}})));
        Modelica.Blocks.Math.Product PMOT annotation (
          Placement(transformation(extent = {{-72, 0}, {-52, 20}})));
        Modelica.Blocks.Math.Gain normalizeSpeed(k = 1 / wMax) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-34, -40})));
      equation
        connect(tau, abs2.u) annotation (
          Line(points = {{-120, 40}, {-94, 40}, {-94, 50}, {-82, 50}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(w, abs1.u) annotation (
          Line(points = {{-120, -40}, {-78, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(abs2.y, normalizeTau.u) annotation (
          Line(points = {{-59, 50}, {-48, 50}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(normalizeTau.y, effTable_.u1) annotation (
          Line(points = {{-25, 50}, {-7.7, 50}, {-7.7, -9.6}, {1.2, -9.6}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(applyEta.Pel, elePow) annotation (
          Line(points = {{85.2, 1}, {92.48, 1}, {92.48, 0}, {106, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(effTable_.y, applyEta.eta) annotation (
          Line(points = {{33.4, -18}, {46, -18}, {46, -5.6}, {57.6, -5.6}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(PMOT.u1, tau) annotation (
          Line(points = {{-74, 16}, {-84, 16}, {-84, 40}, {-120, 40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(PMOT.u2, w) annotation (
          Line(points = {{-74, 4}, {-84, 4}, {-84, -40}, {-120, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(PMOT.y, applyEta.P) annotation (
          Line(points = {{-51, 10}, {42, 10}, {42, 7.6}, {57.6, 7.6}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(abs1.y, normalizeSpeed.u) annotation (
          Line(points = {{-55, -40}, {-46, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(normalizeSpeed.y, effTable_.u2) annotation (
          Line(points = {{-23, -40}, {-10, -40}, {-10, -26.4}, {1.2, -26.4}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 72}, {100, -72}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-74, -54}, {-74, 58}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-82, -48}, {78, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-74, 38}, {-24, 38}, {-4, 12}, {28, -8}, {60, -22}, {62, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{-20, 14}, {-40, 24}, {-56, -4}, {-38, -36}, {12, -38}, {26, -28}, {22, -20}, {8, -6}, {-8, 4}, {-20, 14}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 4}, {-38, 2}, {-32, -20}, {0, -32}, {10, -28}, {12, -20}, {-28, 4}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-102, 118}, {100, 78}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{26, 46}, {76, 4}}, lineColor = {0, 0, 0}, textString = "T")}),
          Documentation(info = "<html>
<p>This block computes the machine and inverter losses from the mechanical input quantities and determines the power to be drawn from the electric circuit. The &QUOT;drawn&QUOT; power can be also a negative numer, meaning that themachine is actually delivering electric power.</p>
<p>The given efficiency map is intended as being built with torques being ratios of actual torques to tauMax and speeds being ratios of w to wMax. In case the user uses, in the given efficiency map, torques in Nm and speeds in rad/s, the block can be used selecting tauTmax=1, wMax=1.</p>
<p>The choice of having normalised efficiency computation allows simulations of machines different in sizes and similar in characteristics to be repeated without having to rebuild the efficiency maps. </p>
<p>Torques are written in the first matrix column, speeds on the first row.</p>
</html>"));
      end EfficiencyT;

      block EfficiencyLF "Determines the electric from the mechanical power considering loss with a formula"
        import wbEHPTlib =
               EHPTlib;
        parameter Modelica.SIunits.Torque tauMax(start = 400) "Maximum machine torque(Nm)";
        parameter Modelica.SIunits.Power powMax(start = 22000) "Maximum drive power";
        parameter Modelica.SIunits.AngularVelocity wMax(start = 650) "Maximum machine speed(rad/s)";
        parameter Real effTable[:, :] = [0.00, 0.00, 0.25, 0.50, 0.75, 1.00; 0.00, 0.75, 0.80, 0.81, 0.82, 0.83; 0.25, 0.76, 0.81, 0.82, 0.83, 0.84; 0.50, 0.77, 0.82, 0.83, 0.84, 0.85; 0.75, 0.78, 0.83, 0.84, 0.85, 0.87; 1.00, 0.80, 0.84, 0.85, 0.86, 0.88];
        Modelica.Blocks.Interfaces.RealInput w annotation (
          Placement(transformation(extent = {{-140, -60}, {-100, -20}}), iconTransformation(extent = {{-140, -60}, {-100, -20}})));
        Modelica.Blocks.Interfaces.RealInput tau annotation (
          Placement(transformation(extent = {{-140, 20}, {-100, 60}}), iconTransformation(extent = {{-140, 20}, {-100, 60}})));
        Modelica.Blocks.Interfaces.RealOutput elePow annotation (
          Placement(transformation(extent = {{96, -10}, {116, 10}})));
        Modelica.Blocks.Math.Abs abs1 annotation (
          Placement(transformation(extent = {{-76, -50}, {-56, -30}})));
        Modelica.Blocks.Math.Abs abs2 annotation (
          Placement(transformation(extent = {{-80, 40}, {-60, 60}})));
        Modelica.Blocks.Math.Gain normalizeTau(k = 1 / tauMax) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-36, 50})));
        Modelica.Blocks.Math.Gain normalizeSpeed(k = 1 / wMax) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-34, -40})));
        wbEHPTlib.SupportModels.MapBasedRelated.AddLossesWT addLosses annotation (
          Placement(transformation(extent = {{10, -10}, {30, 10}})));
      equation
        connect(tau, abs2.u) annotation (
          Line(points = {{-120, 40}, {-94, 40}, {-94, 50}, {-82, 50}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(w, abs1.u) annotation (
          Line(points = {{-120, -40}, {-78, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(abs2.y, normalizeTau.u) annotation (
          Line(points = {{-59, 50}, {-48, 50}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(abs1.y, normalizeSpeed.u) annotation (
          Line(points = {{-55, -40}, {-46, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(addLosses.T, normalizeTau.y) annotation (
          Line(points = {{8.2, 6}, {-18, 6}, {-18, 50}, {-25, 50}}, color = {0, 0, 127}));
        connect(addLosses.W, normalizeSpeed.y) annotation (
          Line(points = {{8.2, -6}, {-18, -6}, {-18, -40}, {-23, -40}}, color = {0, 0, 127}));
        connect(addLosses.y, elePow) annotation (
          Line(points = {{30.6, 0}, {30.6, 0}, {106, 0}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 72}, {100, -72}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-74, -54}, {-74, 58}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-82, -48}, {78, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-74, 38}, {-24, 38}, {-4, 12}, {28, -8}, {60, -22}, {62, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{-20, 14}, {-40, 24}, {-56, -4}, {-38, -36}, {12, -38}, {26, -28}, {22, -20}, {8, -6}, {-8, 4}, {-20, 14}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 4}, {-38, 2}, {-32, -20}, {0, -32}, {10, -28}, {12, -20}, {-28, 4}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-102, 118}, {100, 78}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{26, 46}, {76, 4}}, lineColor = {0, 0, 0}, textString = "L")}),
          Documentation(info = "<html>
<p>This block computes the machine and inverter losses from the mechanical input quantities and determines the power to be drawn from the electric circuit. The &QUOT;drawn&QUOT; power can be also a negative numer, meaning that the machine is actually delivering electric power.</p>
<p>The signs ot T and W must be such that their product is positive when mechanical power exits from the machine (electric motor operation)</p>
</html>"));
      end EfficiencyLF;

      block EffiPlot "Utility to plot efficiencies from an effTable"
        import wbEHPTlib =
               EHPTlib;
        parameter Real tauMax(start = 400) "Maximum machine torque(Nm)";
        parameter Real powMax(start = 22000) "Maximum drive power";
        parameter Real wMax(start = 650) "Maximum machine speed(rad/s)";
        parameter Real effTable[:, :] = [0.00, 0.00, 0.25, 0.50, 0.75, 1.00; 0.00, 0.75, 0.80, 0.81, 0.82, 0.83; 0.25, 0.76, 0.81, 0.82, 0.83, 0.84; 0.50, 0.77, 0.82, 0.83, 0.84, 0.85; 0.75, 0.78, 0.83, 0.84, 0.85, 0.87; 1.00, 0.80, 0.84, 0.85, 0.86, 0.88];
        Real tau[size(effs, 1)];
        Real effs[:] = {0.75, 0.775, 0.8, 0.825, 0.85, 0.875};
        Modelica.Blocks.Tables.CombiTable2D effTable_[size(effs, 1)](each tableOnFile = false, each smoothness = Modelica.Blocks.Types.Smoothness.LinearSegments, each table = effTable) "normalised efficiency" annotation (
          Placement(transformation(extent = {{-14, -14}, {14, 14}}, rotation = 0, origin = {-2, 0})));
      equation
        for i in 1:size(effs, 1) loop
          effTable_[i].y = effs[i];
          effTable_[i].u1 = time;
          effTable_[i].u2 = tau[i];
        end for;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 72}, {100, -72}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-74, -54}, {-74, 58}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-82, -48}, {78, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-74, 38}, {-24, 38}, {-4, 12}, {28, -8}, {60, -22}, {62, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{-20, 14}, {-40, 24}, {-56, -4}, {-38, -36}, {12, -38}, {26, -28}, {22, -20}, {8, -6}, {-8, 4}, {-20, 14}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 4}, {-38, 2}, {-32, -20}, {0, -32}, {10, -28}, {12, -20}, {-28, 4}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-102, 118}, {100, 78}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{26, 46}, {76, 4}}, lineColor = {0, 0, 0}, textString = "M")}),
          Documentation(info = "<html>
<p>This block computes the machine and inverter losses from the mechanical input quantities and determines the power to be drawn from the electric circuit. The &QUOT;drawn&QUOT; power can be also a negative numer, meaning that themachine is actually delivering electric power.</p>
<p>The given efficiency map is intended as being built with torques being ratios of actual torques to tauMax and speeds being ratios of w to wMax. In case the user uses, in the given efficiency map, torques in Nm and speeds in rad/s, the block can be used selecting tauTmax=1, wMax=1.</p>
<p>The choice of having normalised efficiency computation allows simulations of machines different in sizes and similar in characteristics to be repeated without having to rebuild the efficiency maps. </p>
<p>Torques are written in the first matrix column, speeds on the first row.</p>
</html>"));
      end EffiPlot;

      block EffiPlot2 "Utility to plot efficiencies from an effTable"
        import wbEHPTlib =
               EHPTlib;
        parameter Modelica.SIunits.Torque tauMax(start = 400) "Maximum machine torque(Nm)";
        parameter Modelica.SIunits.Power powMax(start = 22000) "Maximum drive power";
        parameter Modelica.SIunits.AngularVelocity wMax(start = 650) "Maximum machine speed(rad/s)";

        function eff
          input Real A, bT, bS, bP;
          input Real tq "input torque";
          input Real sp "input speed";
          output Real eff;
        protected
          Real pLoss;
        algorithm
          pLoss := A + bT * tq ^ 2 + bS * sp ^ 2 + bP * (tq * sp) ^ 2;
          eff := tq * sp / (tq * sp + pLoss);
        end eff;

        function lossFun
          input Real A, bT, bS, bP;
          input Real tq "input torque";
          input Real sp "input speed";
          output Real pLoss;
        algorithm
          pLoss := A + bT * tq ^ 2 + bS * sp ^ 2 + bP * (tq * sp) ^ 2;
        end lossFun;

        Real tauE[size(effs, 1)];
        Real tauL[size(loss, 1)];
        Real loss[:] = {0.02, 0.04, 0.06, 0.08};
        Real effs[:] = {0.75, 0.8, 0.85, 0.9};
      equation
        for i in 1:size(effs, 1) loop
          effs[i] = eff(0.0005, 0.02, 0.01, 0.025, tauE[i], time);
        end for;
        for i in 1:size(loss, 1) loop
          loss[i] = lossFun(0.0005, 0.02, 0.01, 0.025, tauL[i], time);
        end for;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 72}, {100, -72}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-74, -54}, {-74, 58}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-82, -48}, {78, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-74, 38}, {-24, 38}, {-4, 12}, {28, -8}, {60, -22}, {62, -48}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{-20, 14}, {-40, 24}, {-56, -4}, {-38, -36}, {12, -38}, {26, -28}, {22, -20}, {8, -6}, {-8, 4}, {-20, 14}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 4}, {-38, 2}, {-32, -20}, {0, -32}, {10, -28}, {12, -20}, {-28, 4}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-102, 118}, {100, 78}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{26, 46}, {76, 4}}, lineColor = {0, 0, 0}, textString = "M")}),
          Documentation(info = "<html>
<p>Questo modello di ausilio cerca di riprodurre i contour descritti nel file Efficiency.docx.</p>
<p>Nella versione presente ha due difetti fondamentali:</p>
<p>1) non riesce a descrivere curve polidrome a differenza di contour. Questo &egrave; critico in quanto le curve di efficienza sono proprio di questo tipo.</p>
<p>2) non riesce a gestire i casi in cui per un certo vaore della velocit&agrave; non si trova la coppia che da una data perdita. Se ad es. le perdite si cercano a partire da 0.02 dappiako da ecciciency.docx che ha curva delle perdite ha tangente verticale per velocit&agrave; pari a 1.4, ed infatti il modello proposto deve rimanere con 0.02 al di sotto di 1.4, altrimenti non converge.</p>
</html>"),experiment(StartTime = 0.1, StopTime = 1.35));
      end EffiPlot2;

      block AddLossesWT "adds drive losses function of W and T"
        parameter Real A = 0.006 "fixed p.u. losses";
        parameter Real bT(unit = "J/(N2.m2)") = 0.1 "torque losses coefficient";
        parameter Real bW(unit = "J/(rad2.s2)") = 0.1 "speed losses coefficient";
        parameter Real bP(unit = "J/W2") = 0.07 "power losses coefficient";
        Modelica.SIunits.Energy losses;
        Modelica.Blocks.Interfaces.RealInput W annotation (
          Placement(transformation(extent = {{-138, -80}, {-98, -40}})));
        Modelica.Blocks.Interfaces.RealOutput y annotation (
          Placement(transformation(extent = {{96, -10}, {116, 10}})));
        Modelica.Blocks.Interfaces.RealInput T annotation (
          Placement(transformation(extent = {{-138, 40}, {-98, 80}})));
      equation
        losses = A + bT * T ^ 2 + bW * W ^ 2 + bP * (T * W) ^ 2;
        y = T * W + losses;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-20, -22}, {20, -22}, {20, -60}, {40, -60}, {0, -100}, {-40, -60}, {-20, -60}, {-20, -22}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 0, 0}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 75}, {100, 35}}, lineColor = {0, 0, 127}, fillColor = {255, 0, 0}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{-70, 10}, {74, -16}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "W-T")}));
      end AddLossesWT;

      model ConstPg "Constant Power DC Load"
        parameter Real vNom = 100;
        parameter Modelica.SIunits.Time Ti = 0.01 "inner PI follower integral time constant";
        Real v "DC voltage";
        Modelica.Blocks.Math.Feedback feedback1 annotation (
          Placement(visible = true, transformation(origin = {56, -44}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
          Placement(visible = true, transformation(extent = {{-108, 58}, {-88, 78}}, rotation = 0), iconTransformation(extent = {{-10, 90}, {10, 110}}, rotation = 0)));
        Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
          Placement(visible = true, transformation(extent = {{-108, -74}, {-88, -54}}, rotation = 0), iconTransformation(extent = {{-10, -108}, {10, -88}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealInput Pref "Reference power" annotation (
          Placement(visible = true, transformation(origin = {100, -44}, extent = {{-18, -18}, {18, 18}}, rotation = 180), iconTransformation(origin = {82, 0}, extent = {{-18, -18}, {18, 18}}, rotation = 180)));
        Modelica.Electrical.Analog.Sensors.PowerSensor pSensor annotation (
          Placement(visible = true, transformation(extent = {{-82, 58}, {-62, 78}}, rotation = 0)));
        Modelica.Electrical.Analog.Basic.VariableConductor varCond annotation (
          Placement(visible = true, transformation(origin = {-50, 0}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Continuous.Integrator integrator1(k = 1 / vNom ^ 2 / Ti) annotation (
          Placement(visible = true, transformation(origin = {-2, -44}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
      equation
        connect(integrator1.u, feedback1.y) annotation (
          Line(points = {{10, -44}, {47, -44}}, color = {0, 0, 127}));
        connect(integrator1.y, varCond.G) annotation (
          Line(points = {{-13, -44}, {-28, -44}, {-28, 0}, {-39, 0}}, color = {0, 0, 127}));
        connect(feedback1.u2, pSensor.power) annotation (
          Line(points = {{56, -36}, {56, 42}, {-80, 42}, {-80, 57}}, color = {0, 0, 127}));
        connect(varCond.n, pin_n) annotation (
          Line(points = {{-50, -10}, {-50, -10}, {-50, -64}, {-98, -64}, {-98, -64}}, color = {0, 0, 255}));
        connect(varCond.p, pSensor.nc) annotation (
          Line(points = {{-50, 10}, {-50, 10}, {-50, 68}, {-62, 68}, {-62, 68}}, color = {0, 0, 255}));
        connect(pSensor.pv, pSensor.pc) annotation (
          Line(points = {{-72, 78}, {-82, 78}, {-82, 68}}, color = {0, 0, 255}));
        connect(pSensor.pc, pin_p) annotation (
          Line(points = {{-82, 68}, {-98, 68}}, color = {0, 0, 255}));
        connect(pSensor.nv, pin_n) annotation (
          Line(points = {{-72, 58}, {-72, -64}, {-98, -64}}, color = {0, 0, 255}));
        connect(feedback1.u1, Pref) annotation (
          Line(points = {{64, -44}, {100, -44}}, color = {0, 0, 127}));
        v = pin_p.v - pin_n.v;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics),
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Line(points = {{-4, 0}, {70, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{0, 94}, {0, -88}, {-2, -90}}, color = {0, 0, 255}, smooth = Smooth.None), Rectangle(extent = {{-28, 68}, {28, -52}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{42, 58}, {78, 22}}, lineColor = {255, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "P")}),
          Documentation(info = "<html>
    <p>Questo componente simula, mediante inseguimento di un riferimento esterno, un carico a potenza costante.</p>
    <p>I parametri k e T sono i parametri del regolatore PI che insegue l&apos;input. TIpicamente si potr&agrave; utilizzare k=1 e T di un ordine di grandezza pi&ugrave; piccolo delle costanti di tempo del segnale di ingresso di potenza</p>
    </html>"));
      end ConstPg;

      block LimTau "Torque limiter"
        Modelica.Blocks.Interfaces.RealInput w annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealOutput yH annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}})));
        parameter Modelica.SIunits.Power powMax = 50000 "Maximum mechanical power";
        parameter Modelica.SIunits.Torque tauMax = 400 "Maximum torque ";
        parameter Modelica.SIunits.AngularVelocity wMax(min = powMax / tauMax) = 1500 "Maximum speed";
        Integer state "=0 below base speed; =1 before wMax; =2 in w limit, =3 above wMax";
        //0 or 1 if tauMax or powMax is delivered; =2 or 3 if w>wMax
      protected
        parameter Real alpha = 0.10 "fraction of wMax over which the torque is to be brought to zero";
      public
        Modelica.Blocks.Interfaces.RealOutput yL annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}})));
      algorithm
        if w < powMax / tauMax then
          state := 0;
          yH := tauMax;
        else
          state := 1;
          yH := powMax / w;
        end if;
        //over wMax the torque max is to be rapidly brought to zero
        if w > wMax then
          if w < (1 + alpha) * wMax then
            state := 2;
            yH := powMax / wMax * (1 - (w - wMax) / (alpha * wMax));
          else
            state := 3;
            yH := 0;
          end if;
        end if;
        yL := -yH;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Text(extent = {{-98, 126}, {96, 90}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name
          "), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 90}, {100, -88}}), Line(points = {{-72, 80}, {-72, -80}}, arrow = {Arrow.Filled, Arrow.None}, arrowSize = 2), Text(lineColor = {0, 0, 255}, extent = {{-98, 54}, {-84, 48}}, textString = "T"), Line(points = {{92, -2}, {-74, -2}}, arrow = {Arrow.Filled, Arrow.None}, arrowSize = 2), Text(lineColor = {0, 0, 255}, extent = {{72, -22}, {86, -28}}, textString = "W"), Line(points = {{-72, 54}, {-12, 54}, {-2, 40}, {16, 26}, {30, 18}, {44, 14}}), Line(points = {{-72, -58}, {-12, -58}, {-2, -44}, {16, -30}, {30, -22}, {42, -18}})}),
          Documentation(info = "<html>
      <p>Gives the maximum output torque as a function of the input speed.</p>
      <p>When w&LT;wMax the output is Tmax if Tmax*w&LT;Pnom, othersise it is Pnom/w</p>
      <p>But if w is over wMax Tmax is rapidly falling to zero (reaches zero when speed overcomes wMax by 10&percnt;).</p>
      <p>Torques and powers are in SI units</p>
      </html>"));
      end LimTau;

      block Pel "Outputs a power signal computed from the given efficiency and input power"
        Modelica.Blocks.Interfaces.RealInput eta "efficiency" annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}}), iconTransformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.RealInput P "Delivered Mechanical Power" annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}}), iconTransformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealOutput Pel "Absorbed Electrical power" annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}})));
      algorithm
        if noEvent(P <= 0) then
          Pel := P * eta;
        else
          Pel := P / eta;
        end if;
        annotation (
          Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-78, 82}, {70, -92}}, lineColor = {0, 0, 127}, fillColor = {170, 255, 255}, fillPattern = FillPattern.Solid, textString = "Pmecc
to
Pel")}),  Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics),
          Documentation(info = "<html>
<pre><span style=\"font-family: Courier New,courier;\">Outputs&nbsp;a power signal computed from the&nbsp;given&nbsp;efficiency&nbsp;and&nbsp;input&nbsp;power</span></pre>
</html>"));
      end Pel;

      block LimTorque "Torque limiter"
        Modelica.Blocks.Interfaces.RealInput w annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealOutput yH annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}})));
        parameter Boolean limitsOnFile = false "= true, if max torque is taken from a txt file";
        parameter Modelica.SIunits.Power powMax = 50000 "Maximum mechanical power" annotation (
          Dialog(enable = not limitsOnFile));
        parameter Modelica.SIunits.Torque tauMax = 400 "Maximum torque" annotation (
          Dialog(enable = not limitsOnFile));
        parameter Modelica.SIunits.AngularVelocity wMax(min = powMax / tauMax) = 1500 "Maximum speed" annotation (
          Dialog(enable = not limitsOnFile));
        parameter String limitsFileName = "noName" "File where matrix is stored" annotation (
          Dialog(enable = limitsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required table is")));
        parameter String maxTorqueTableName = "noName" "Name of the on-file maximum torque as a function of speed" annotation (
          Dialog(enable = limitsOnFile));
        parameter String minTorqueTableName = "noName" "Name of the on-file minimum torque as a function of speed" annotation (
          Dialog(enable = limitsOnFile));
        Integer state "=0 below base speed; =1 before wMax; =2 in w limit, =3 above wMax";
        //0 or 1 if tauMax or powMax is delivered; =2 or 3 if w>wMax; -1 if limitsOnFile
        Real yHidealised "valore del limite di coppia in caso di curve idealizzate (T cost. sotto la velocità base, P cost. sopra)";
      protected
        parameter Real alpha = 0.10 "fraction of wMax over which the torque is to be brought to zero";
      public
        Modelica.Blocks.Interfaces.RealOutput yL annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Tables.CombiTable1Ds toMaxTq(tableOnFile = limitsOnFile, table = [0, 0; 1, 1; 2, 4], tableName = maxTorqueTableName, fileName = limitsFileName, smoothness = Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative2, extrapolation = Modelica.Blocks.Types.Extrapolation.LastTwoPoints) annotation (
          Placement(transformation(extent = {{-10, 30}, {10, 50}})));
        Modelica.Blocks.Tables.CombiTable1Ds toMinTq(tableOnFile = limitsOnFile, table = [0, 0; 1, 1; 2, 4], tableName = minTorqueTableName, fileName = limitsFileName, smoothness = Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative2, extrapolation = Modelica.Blocks.Types.Extrapolation.LastTwoPoints) annotation (
          Placement(transformation(extent = {{-10, -50}, {10, -30}})));
        Modelica.Blocks.Math.UnitConversions.To_rpm to_rpm annotation (
          Placement(transformation(extent = {{-78, -10}, {-58, 10}})));
      algorithm
        if w < powMax / tauMax then
          state := 0;
          yHidealised := tauMax;
        else
          state := 1;
          yHidealised := powMax / w;
        end if;
        //over wMax the torque max is to be rapidly brought to zero
        if w > wMax then
          if w < (1 + alpha) * wMax then
            state := 2;
            yHidealised := powMax / wMax * (1 - (w - wMax) / (alpha * wMax));
          else
            state := 3;
            yHidealised := 0;
          end if;
        end if;
        if limitsOnFile then
          state := -1;
        end if;
      equation
        if limitsOnFile then
          yH = toMaxTq.y[1];
          yL = toMinTq.y[1];
        else
          yH = yHidealised;
          yL = -yHidealised;
        end if;
        connect(w, to_rpm.u) annotation (
          Line(points = {{-120, 0}, {-80, 0}}, color = {0, 0, 127}));
        connect(toMaxTq.u, toMinTq.u) annotation (
          Line(points = {{-12, 40}, {-30, 40}, {-30, -40}, {-12, -40}}, color = {0, 0, 127}));
        connect(to_rpm.y, toMinTq.u) annotation (
          Line(points = {{-57, 0}, {-30, 0}, {-30, -40}, {-12, -40}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Text(extent = {{-100, 120}, {98, 68}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name
          "), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 90}, {100, -88}}), Line(points = {{-72, 80}, {-72, -80}}, arrow = {Arrow.Filled, Arrow.None}, arrowSize = 2), Text(lineColor = {0, 0, 255}, extent = {{-98, 54}, {-84, 48}}, textString = "T"), Line(points = {{92, -2}, {-74, -2}}, arrow = {Arrow.Filled, Arrow.None}, arrowSize = 2), Text(lineColor = {0, 0, 255}, extent = {{72, -22}, {86, -28}}, textString = "W"), Line(points = {{-72, 54}, {-12, 54}, {2, 46}, {16, 26}, {30, 18}, {43.9863, 14.0039}, {86, 10}}, color = {0, 0, 0}, thickness = 0.5), Line(points = {{-72, -2}, {-62, -2}, {-52, -48}, {-8, -48}, {4, -42}, {16, -20}, {34, -12}, {86, -8}}, color = {0, 0, 0}, thickness = 0.5)}),
          Documentation(info = "<html>
<p>Gives the maximum output torque as a function of the input speed. </p>
<p>There are two possibilities dependig on the value of limitsOnFile.</p>
<p><b>If limitsOnFile=false</b></p>
<p>When w&lt;wMax the output is Tmax if Tmax*w&lt;Pnom, othersise it is Pnom/w </p>
<p>But if w is over wMax Tmax is rapidly falling to zero (reaches zero when speed overcomes wMax by 10&percnt;). </p>
<p><b>If limitsOnFile=true</b></p>
<p>maximum and minimum torques arre taken from a txt file. Default interpaltion is with ontinuous derivative. No maxmimum speed is considered.</p>
<p><br>Torques and powers are in SI units </p>
</html>"));
      end LimTorque;
    end MapBasedRelated;

    package Miscellaneous
      block Greater "Output y is true, if input u1 is greater than input u2"
        extends PartialBooleanComparison;
      equation
        y = u1 > u2;
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Ellipse(lineColor = {0, 0, 127}, extent = {{32, 10}, {52, -10}}, endAngle = 360), Line(points = {{-100, -80}, {42, -80}, {42, 0}}, color = {0, 0, 127}), Line(points = {{-54, 22}, {-8, 2}, {-54, -18}}, thickness = 0.5), Text(origin = {-20, 133}, lineColor = {0, 0, 255}, extent = {{-96, 25}, {122, -19}}, textString = "%name")}),
          Documentation(info = "<html>
<p>
The output is <b>true</b> if Real input u1 is greater than
Real input u2, otherwise the output is <b>false</b>.
</p>
</html>"));
      end Greater;

      partial block PartialBooleanComparison "Partial block with 2 Real input and 1 Boolean output signal (the result of a comparison of the two Real inputs)"
        Modelica.Blocks.Interfaces.RealInput u1 "Connector of first Real input signal" annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealInput u2 "Connector of second Real input signal" annotation (
          Placement(transformation(extent = {{-140, -100}, {-100, -60}})));
        Modelica.Blocks.Interfaces.BooleanOutput y "Connector of Boolean output signal" annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}})));
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillColor = {210, 210, 210}, fillPattern = FillPattern.Solid, borderPattern = BorderPattern.Raised), Ellipse(extent = {{73, 7}, {87, -7}}, lineColor = DynamicSelect({235, 235, 235}, if y > 0.5 then {0, 255, 0} else {235, 235, 235}), fillColor = DynamicSelect({235, 235, 235}, if y > 0.5 then {0, 255, 0} else {235, 235, 235}), fillPattern = FillPattern.Solid), Ellipse(extent = {{32, 10}, {52, -10}}, lineColor = {0, 0, 127}), Line(points = {{-100, -80}, {42, -80}, {42, 0}}, color = {0, 0, 127})}),
          Documentation(info = "<html>
<p>
Block has two continuous Real input and one continuous Boolean output signal
as a result of the comparison of the two input signals. The block
has a 3D icon (e.g., used in Blocks.Logical library).
</p>
</html>"));
      end PartialBooleanComparison;

      model DragForce "Vehicle rolling and aerodinamical drag force"
        import Modelica.Constants.g_n;
        extends
          Modelica.Mechanics.Translational.Interfaces.PartialElementaryOneFlangeAndSupport2;
        extends Modelica.Mechanics.Translational.Interfaces.PartialFriction;
        Modelica.SIunits.Force f "Total drag force";
        Modelica.SIunits.Velocity v "vehicle velocity";
        Modelica.SIunits.Acceleration a "Absolute acceleration of flange";
        Real Sign;
        parameter Modelica.SIunits.Mass m "vehicle mass";
        parameter Modelica.SIunits.Density rho = 1.226 "air density";
        parameter Modelica.SIunits.Area S "vehicle cross area";
        parameter Real fc(start = 0.01) "rolling friction coefficient";
        parameter Real Cx "aerodinamic drag coefficient";
      protected
        parameter Real A = fc * m * g_n;
        parameter Real B = 1 / 2 * rho * S * Cx;
      equation
        //  s = flange.s;
        v = der(s);
        a = der(v);
        // Le seguenti definizioni seguono l'ordine e le richieste del modello "PartialFriction" di
        // Modelica.Mechanics.Translational.Interfaces"
        v_relfric = v;
        a_relfric = a;
        f0 = A "force at 0 speed 0 but with slip";
        f0_max = A "max force at 0 speed without slip";
        free = false "in principle should become true whenthe wheel loose contact with road";
        // Now the computation of f, and its attribution to the flange:
        flange.f - f = 0;
        // friction force
        if v > 0 then
          Sign = 1;
        else
          Sign = -1;
        end if;
        //The following equation equates dragForce to the force applied when looocked)true, otherwise term A.
        f - B * v ^ 2 * Sign = if locked then sa * unitForce else f0 * (if startForward then Modelica.Math.tempInterpol1(v, [0, 1], 2) else if startBackward then -Modelica.Math.tempInterpol1(-v, [0, 1], 2) else if pre(mode) == Forward then Modelica.Math.tempInterpol1(v, [0, 1], 2) else -Modelica.Math.tempInterpol1(-v, [0, 1], 2));
        annotation (
          Documentation(info = "<html>
<p>This component models the total (rolling and aerodynamic) vehicle drag resistance: </p>
<p>F=fc*m*g+(1/2)*rho*Cx*S*v^2 </p>
<p>It models reliably the stuck phase. Based on Modelica-Intrerfaces.PartialFriction model </p>
</html>"),Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Polygon(points = {{-98, 10}, {22, 10}, {22, 41}, {92, 0}, {22, -41}, {22, -10}, {-98, -10}, {-98, 10}}, lineColor = {0, 127, 0}, fillColor = {215, 215, 215}, fillPattern = FillPattern.Solid), Line(points = {{-42, -50}, {87, -50}}, color = {0, 0, 0}), Polygon(points = {{-72, -50}, {-41, -40}, {-41, -60}, {-72, -50}}, lineColor = {0, 0, 0}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Line(points = {{-90, -90}, {-70, -88}, {-50, -82}, {-30, -72}, {-10, -58}, {10, -40}, {30, -18}, {50, 8}, {70, 38}, {90, 72}, {110, 110}}, color = {0, 0, 255}, thickness = 0.5), Text(extent = {{-82, 90}, {80, 50}}, lineColor = {0, 0, 255}, textString = "%name")}),
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics));
      end DragForce;

      block PropDriver "Simple Proportional controller driver"
        parameter String CycleFileName = "cycleName.txt" "Drive Cycle Name ex: \"sort1.txt\"";
        parameter Real k "Controller gain";
        parameter Real yMax = 1.e6 "Max output value (absolute)";
        parameter Modelica.Blocks.Types.Extrapolation extrapolation = Modelica.Blocks.Types.Extrapolation.LastTwoPoints "Extrapolation of data outside the definition range";
      protected
        parameter Boolean dummy(fixed = false);
        //Used only to render exrapolation a structural parameter.
        // This is important, otherwise the user could falsely believe that they can change it at run time,
        //which is not possible because it is passed to a CombiTable for which (at least in OpenModelica),
        //the extrapolation parameter is structural.
      public
        Modelica.Blocks.Interfaces.RealInput V annotation (
          Placement(visible = true, transformation(origin = {0, -66}, extent = {{-14, -14}, {14, 14}}, rotation = 90), iconTransformation(origin = {0, -112}, extent = {{-12, -12}, {12, 12}}, rotation = 90)));
        Modelica.Blocks.Math.UnitConversions.From_kmh from_kmh annotation (
          Placement(visible = true, transformation(extent = {{-42, -10}, {-22, 10}}, rotation = 0)));
        Modelica.Blocks.Sources.CombiTimeTable driveCyc(columns = {2}, extrapolation = extrapolation, fileName = CycleFileName, tableName = "Cycle", tableOnFile = true) annotation (
          Placement(visible = true, transformation(extent = {{-80, -10}, {-60, 10}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = k) annotation (
          Placement(visible = true, transformation(extent = {{14, -10}, {34, 10}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limAcc(uMax = yMax, uMin = 0) annotation (
          Placement(visible = true, transformation(origin = {2, 40}, extent = {{52, -10}, {72, 10}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limBrak(uMax = 0, uMin = -yMax) annotation (
          Placement(visible = true, transformation(origin = {0, -40}, extent = {{52, -10}, {72, 10}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput tauRef(unit = "N.m") annotation (
          Placement(visible = true, transformation(extent = {{100, -10}, {120, 10}}, rotation = 0), iconTransformation(extent = {{100, -10}, {120, 10}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput accelTau(unit = "N.m") annotation (
          Placement(visible = true, transformation(origin = {110, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(extent = {{100, 52}, {120, 72}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput brakeTau(unit = "N.m") annotation (
          Placement(visible = true, transformation(origin = {110, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(extent = {{100, -70}, {120, -50}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limiter1(limitsAtInit = true, uMax = yMax) annotation (
          Placement(visible = true, transformation(origin = {4, 0}, extent = {{52, -10}, {72, 10}}, rotation = 0)));
      initial equation
        //For the meaning of the following if see the definition of dummy
        if extrapolation == Modelica.Blocks.Types.Extrapolation.HoldLastPoint then
          dummy = true;
        else
          dummy = false;
        end if;
      equation
        connect(V, feedback.u2) annotation (
          Line(points = {{0, -66}, {0, -66}, {0, -8}, {0, -8}}, color = {0, 0, 127}));
        connect(from_kmh.u, driveCyc.y[1]) annotation (
          Line(points = {{-44, 0}, {-59, 0}}, color = {0, 0, 127}));
        connect(from_kmh.y, feedback.u1) annotation (
          Line(points = {{-21, 0}, {-8, 0}}, color = {0, 0, 127}));
        connect(feedback.y, gain.u) annotation (
          Line(points = {{9, 0}, {12, 0}}, color = {0, 0, 127}));
        connect(limBrak.y, brakeTau) annotation (
          Line(points = {{73, -40}, {104, -40}, {104, -40}, {110, -40}}, color = {0, 0, 127}));
        connect(limAcc.y, accelTau) annotation (
          Line(points = {{75, 40}, {102, 40}, {102, 40}, {110, 40}}, color = {0, 0, 127}));
        connect(limBrak.u, gain.y) annotation (
          Line(points = {{50, -40}, {40, -40}, {40, 0}, {35, 0}, {35, 0}}, color = {0, 0, 127}));
        connect(limAcc.u, gain.y) annotation (
          Line(points = {{52, 40}, {40, 40}, {40, 0}, {35, 0}, {35, 0}}, color = {0, 0, 127}));
        connect(limiter1.u, gain.y) annotation (
          Line(points = {{54, 0}, {34, 0}, {34, 0}, {35, 0}}, color = {0, 0, 127}));
        connect(limiter1.y, tauRef) annotation (
          Line(points = {{77, 0}, {102, 0}, {102, 0}, {110, 0}}, color = {0, 0, 127}));
        annotation (
          Documentation(info = "<html><head></head><body><p>Simple driver model.</p><p>It reads a reference cycle from a file then controls speed with a simple proportional feedback law.</p>
            </body></html>"),
          Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Ellipse(fillColor = {255, 213, 170}, fillPattern = FillPattern.Solid, extent = {{-23, 22}, {-12, -4}}, endAngle = 360), Text(origin = {2, -0.1894}, lineColor = {0, 0, 255}, extent = {{-104, 142.189}, {98, 104}}, textString = "%name"), Polygon(fillColor = {215, 215, 215}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-22, -60}, {-42, -88}, {-16, -88}, {16, -88}, {-22, -60}}), Polygon(fillColor = {135, 135, 135}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-32, 40}, {-62, -52}, {-30, -52}, {-30, -52}, {-32, 40}}, smooth = Smooth.Bezier), Polygon(fillColor = {135, 135, 135}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-68, -36}, {-14, -90}, {10, -50}, {0, -50}, {-68, -36}}, smooth = Smooth.Bezier), Polygon(fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid, points = {{-22, 10}, {-30, 6}, {-40, -48}, {2, -46}, {2, -34}, {0, 2}, {-22, 10}}, smooth = Smooth.Bezier), Ellipse(fillColor = {255, 213, 170}, fillPattern = FillPattern.Solid, extent = {{-30, 44}, {-3, 10}}, endAngle = 360), Polygon(pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-38, 34}, {-16, 50}, {-2, 36}, {4, 36}, {6, 36}, {-38, 34}}, smooth = Smooth.Bezier), Polygon(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, points = {{30, -44}, {-32, -28}, {-36, -44}, {-24, -58}, {30, -44}}, smooth = Smooth.Bezier), Polygon(fillPattern = FillPattern.Solid, points = {{42, -70}, {36, -84}, {48, -78}, {52, -72}, {50, -68}, {42, -70}}, smooth = Smooth.Bezier), Line(points = {{48, -14}, {26, 0}, {26, 0}}, thickness = 0.5), Line(points = {{20, -10}, {34, 10}, {34, 10}}, thickness = 0.5), Polygon(fillColor = {255, 213, 170}, fillPattern = FillPattern.Solid, points = {{28, 4}, {32, 8}, {28, 2}, {34, 6}, {30, 2}, {34, 4}, {30, 0}, {26, 2}, {34, 0}, {26, 0}, {26, 2}, {28, 4}, {28, 4}, {26, 2}, {26, 2}, {26, 2}, {28, 8}, {28, 6}, {28, 4}}, smooth = Smooth.Bezier), Polygon(fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid, points = {{-18, 0}, {28, 6}, {26, -2}, {-16, -16}, {-20, -16}, {-24, -6}, {-18, 0}}, smooth = Smooth.Bezier), Polygon(fillColor = {215, 215, 215}, fillPattern = FillPattern.Solid, points = {{72, -6}, {48, -6}, {36, -26}, {58, -86}, {72, -86}, {72, -6}}), Polygon(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, points = {{49, -94}, {17, -40}, {7, -44}, {-1, -50}, {49, -94}}, smooth = Smooth.Bezier), Line(points = {{-7, 31}, {-3, 29}}), Line(points = {{-9, 18}, {-5, 18}}), Line(points = {{-7, 31}, {-3, 31}}), Text(lineColor = {238, 46, 47}, extent = {{-100, 90}, {100, 58}}, textString = "%CycleFileName")}),
          Diagram(coordinateSystem(extent = {{-100, -60}, {100, 60}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})));
      end PropDriver;

      model Batt1 "Battery model based on one R-C block in its electric circuit"
        parameter Modelica.SIunits.ElectricCharge QCellNom(min = 0) = 10 * 3600.0 "Nominal electric charge" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Voltage ECellMin(min = 0) = 3.3 "Minimum open source voltage" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Voltage ECellMax(min = 0.0001) = 4.15 "Maximum open source voltage" annotation (
          Dialog(tab = "Cell data"));
        parameter Real SOCMin(min = 0, max = 1) = 0 "Minimum state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Real SOCMax(min = 0, max = 1) = 1 "Maximum state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Real SOCInit(min = 0, max = 1) = 0.5 "Initial state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Modelica.SIunits.Current ICellMax(min = 0) = 10 * QCellNom / 3600.0 "Maximum admissible current" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Resistance R0Cell(min = 0) = 0.05 * ECellMax / ICellMax "Serial resistance \"R0\"" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Modelica.SIunits.Resistance R1Cell(min = 0) = R0Cell "Serial resistance \"R1\"" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Modelica.SIunits.Capacitance C1Cell(min = 0) = 60 / R1Cell "Capacitance in parallel with R1" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Real efficiency(min = 0, max = 0.9999) = 0.85 "Overall charging/discharging energy efficiency" annotation (
          Dialog(group = "Parameters related to losses"));
        parameter Modelica.SIunits.Current iCellEfficiency(min = 0) = 0.5 * ICellMax "Charging/discharging current the efficiency refers to" annotation (
          Dialog(group = "Parameters related to losses"));
        parameter Integer ns = 1 "Number of serial connected cells per string" annotation (
          Dialog(tab = "Battery pack data", group = "Size of the package"));
        parameter Integer np = 1 "Number of parallel connected strings" annotation (
          Dialog(tab = "Battery pack data", group = "Size of the package"));
        Modelica.SIunits.Voltage uBat(start = EBatteryMin + SOCInit * (EBatteryMax - EBatteryMin), fixed = true);
        Modelica.SIunits.Power powerLoss;
        Modelica.Electrical.Analog.Basic.Capacitor cBattery(final C = CBattery) annotation (
          Placement(transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Electrical.Analog.Basic.Resistor R0(final R = R0Battery) annotation (
          Placement(transformation(origin = {20, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Analog.Sources.SignalCurrent Ip annotation (
          Placement(transformation(origin = {-6, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Electrical.Analog.Interfaces.Pin p annotation (
          Placement(transformation(extent = {{90, 50}, {110, 70}}), iconTransformation(extent = {{90, 50}, {110, 70}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (
          Placement(transformation(extent = {{90, -70}, {110, -50}}), iconTransformation(extent = {{91, -70}, {111, -50}})));
        Modelica.Electrical.Analog.Basic.Resistor R1(final R = R1Battery) annotation (
          Placement(transformation(origin = {-37, 74}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Analog.Basic.Capacitor C1(C = C1Battery) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 180, origin = {-37, 50})));
        Modelica.Blocks.Interfaces.RealOutput SOC annotation (
          Placement(visible = true, transformation(origin = {-90, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180), iconTransformation(origin = {-110, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Analog.Basic.Capacitor cDummy(C = C1Battery / 10000) annotation (
          Placement(visible = true, transformation(origin = {88, 0}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        // The following row is substituted by the next one, since this fomula erroneously mixed cell data with battery data:
        // it would gibe wrong results whenever np>1
        // parameter Real efficiencyMax = (EBatteryMin + EBatteryMax - 2 * Rtot * iCellEfficiency) / (EBatteryMin + EBatteryMax + 2 * Rtot * iCellEfficiency);
      protected
        parameter Real efficiencyMax = (ECellMin + ECellMax - 2 * RtotCell * iCellEfficiency) / (ECellMin + ECellMax + 2 * RtotCell * iCellEfficiency);
        parameter Modelica.SIunits.Capacitance C = QCellNom / (ECellMax - ECellMin) "Cell capacitance";
        // determine fraction of drain current with respect to the total package current
        parameter Real k = ((1 - efficiency) * (EBatteryMax + EBatteryMin) - 2 * (1 + efficiency) * Rtot * iCellEfficiency) / ((1 + efficiency) * (EBatteryMax + EBatteryMin) - 2 * (1 - efficiency) * Rtot * iCellEfficiency);
        parameter Modelica.SIunits.Current IBatteryMax = ICellMax * np "Maximum battery current";
        parameter Modelica.SIunits.Voltage EBatteryMin = ECellMin * ns "Minimum battery voltage";
        parameter Modelica.SIunits.Voltage EBatteryMax = ECellMax * ns "Maximum battery voltage";
        parameter Modelica.SIunits.ElectricCharge QBatteryNominal = QCellNom * np "Battery admissible electric charge";
        parameter Modelica.SIunits.Capacitance CBattery = C * np / ns "Battery capacitance";
        parameter Modelica.SIunits.Resistance R0Battery = R0Cell * ns / np "Serial inner resistance R0 of cell package";
        parameter Modelica.SIunits.Resistance R1Battery = R1Cell * ns / np "Serial inner resistance R1 of cell package";
        parameter Modelica.SIunits.Resistance Rtot = R0Battery + R1Battery;
        parameter Modelica.SIunits.Resistance RtotCell = R0Cell + R1Cell;
        parameter Modelica.SIunits.Capacitance C1Battery = C1Cell * np / ns "Battery series inner capacitance C1";
      protected
        Modelica.SIunits.Voltage ECell "Cell e.m.f.";
        Modelica.SIunits.Current iCellStray "Cell stray current";
        Modelica.SIunits.Voltage EBattery(start = EBatteryMin + SOCInit * (EBatteryMax - EBatteryMin), fixed = true) "Battery e.m.f.";
        Modelica.SIunits.Current iBatteryStray "Cell parasitic current";
        Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation (
          Placement(transformation(extent = {{60, 50}, {80, 70}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = k) annotation (
          Placement(transformation(origin = {52, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Blocks.Math.Abs abs1 annotation (
          Placement(transformation(extent = {{34, -10}, {14, 10}}, rotation = 0)));
      equation
        connect(cDummy.n, n) annotation (
          Line(points = {{88, -10}, {88, -10}, {88, -60}, {100, -60}, {100, -60}}, color = {0, 0, 255}));
        connect(cDummy.p, currentSensor.n) annotation (
          Line(points = {{88, 10}, {88, 10}, {88, 60}, {80, 60}, {80, 60}}, color = {0, 0, 255}));
        assert(SOCMin >= 0, "SOCMin must be greater than, or equal to 0");
        assert(SOCMax <= 1, "SOCMax must be smaller than, or equal to 1");
        assert(efficiency <= efficiencyMax, "Overall charging/discharging energy efficiency is too big with respect to the actual serial resistance (EfficiencyMax =" + String(efficiencyMax) + ")");
        assert(SOCMin < SOCMax, "SOCMax(=" + String(SOCMax) + ") must be greater than SOCMin(=" + String(SOCMin) + ")");
        assert(SOCInit >= SOCMin, "SOCInit(=" + String(SOCInit) + ") must be greater than, or equal to SOCMin(=" + String(SOCMin) + ")");
        assert(SOCInit <= SOCMax, "SOCInit(=" + String(SOCInit) + ") must be smaller than, or equal to SOCMax(=" + String(SOCMax) + ")");
        iBatteryStray = Ip.i;
        iCellStray = iBatteryStray / np;
        EBattery = cBattery.v;
        //Solo per dare maggiore chiarezza all'utente con un nome significativo
        uBat = p.v - n.v;
        powerLoss = R0.LossPower + R1.LossPower + Ip.v * Ip.i;
        ECell = EBattery / ns;
        assert(abs(p.i / np) < ICellMax, "Battery cell current i=" + String(abs(p.i / np)) + "\n exceeds max admissable ICellMax (=" + String(ICellMax) + "A)");
        SOC = (EBattery - EBatteryMin) / (EBatteryMax - EBatteryMin);
        //*(SOCMax-SOCMin)+SOCMin);
        assert(SOC <= SOCMax, "Battery is fully charged: State of charge reached maximum limit (=" + String(SOCMax) + ")");
        assert(SOCMin <= SOC, "Battery is fully discharged: State of charge reached minimum limit (=" + String(SOCMin) + ")");
        connect(R0.p, currentSensor.p) annotation (
          Line(points = {{30, 60}, {60, 60}}, color = {0, 0, 255}));
        connect(Ip.p, R0.n) annotation (
          Line(points = {{-6, 10}, {-6, 60}, {10, 60}}, color = {0, 0, 255}));
        connect(currentSensor.i, gain.u) annotation (
          Line(points = {{70, 50}, {70, -1.46958e-015}, {64, -1.46958e-015}}, color = {0, 0, 127}));
        connect(abs1.u, gain.y) annotation (
          Line(points = {{36, 0}, {39.5, 0}, {39.5, 1.34711e-015}, {41, 1.34711e-015}}, color = {0, 0, 127}));
        connect(abs1.y, Ip.i) annotation (
          Line(points = {{13, 0}, {7, 0}, {7, -1.28588e-015}, {1, -1.28588e-015}}, color = {0, 0, 127}));
        connect(currentSensor.n, p) annotation (
          Line(points = {{80, 60}, {80, 60}, {100, 60}}, color = {0, 0, 255}));
        connect(Ip.n, n) annotation (
          Line(points = {{-6, -10}, {-6, -60}, {100, -60}}, color = {0, 0, 255}));
        connect(n, cBattery.n) annotation (
          Line(points = {{100, -60}, {-60, -60}, {-60, -10}}, color = {0, 0, 255}));
        connect(R1.n, cBattery.p) annotation (
          Line(points = {{-47, 74}, {-60, 74}, {-60, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(C1.n, cBattery.p) annotation (
          Line(points = {{-47, 50}, {-60, 50}, {-60, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(R1.p, C1.p) annotation (
          Line(points = {{-27, 74}, {-18, 74}, {-18, 50}, {-27, 50}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(R1.p, R0.n) annotation (
          Line(points = {{-27, 74}, {-18, 74}, {-18, 60}, {10, 60}}, color = {0, 0, 255}, smooth = Smooth.None));
        annotation (
          Documentation(info = "<html>
<p>Battery model with non-unity coulombic efficiency. </p>
<p>The main cell branch contains an e.m.f. that is linearly increasing with SOC, simulated through an equivalent capacitor, the resistance R0 and a parallel R-C couple. </p>
<p>The full battery is composed by np rows in parallel, each of them containing ns cells in series.</p>
</html>", revisions = "<html><table border=\"1\" rules=\"groups\">
    <thead>
    <tr><td>Version</td>  <td>Date</td>  <td>Comment</td></tr>
    </thead>
    <tbody>
    <tr><td>1.0.0</td>  <td>2006-01-12</td>  <td> </td></tr>
    <tr><td>1.0.3</td>  <td>2006-08-31</td>  <td> Improved assert statements </td></tr>
    <tr><td>1.0.6</td>  <td>2007-05-14</td>  <td> The documentation changed slightly </td></tr>
    </tbody>
    </table>
    </html>"),
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}, grid = {2, 2}), graphics),
          Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(lineColor = {95, 95, 95}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {78, -100}}), Line(origin = {2, -2}, points = {{-92, 7}, {-56, 7}}, color = {0, 0, 255}), Rectangle(lineColor = {0, 0, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Solid, extent = {{-82, -3}, {-65, -10}}), Line(points = {{-73, 63}, {98, 64}}, color = {0, 0, 255}), Rectangle(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{38, 69}, {68, 57}}), Rectangle(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-37.5, 68}, {-6.5, 56}}), Line(points = {{-19.5, 49}, {-19.5, 32}}, color = {0, 0, 255}), Line(points = {{-54.5, 63}, {-54.5, 41}, {-25.5, 41}}, color = {0, 0, 255}), Line(points = {{9.5, 62}, {9.5, 40}, {-19.5, 40}}, color = {0, 0, 255}), Line(points = {{-73, 63}, {-73, 5}}, color = {0, 0, 255}), Line(points = {{-73, -6}, {-73, -60}, {96, -60}}, color = {0, 0, 255}), Line(points = {{26, 63}, {26, -61}}, color = {0, 0, 255}), Line(points = {{-25.5, 49}, {-25.5, 32}}, color = {0, 0, 255}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, points = {{26, 22}, {14, 4}, {26, -14}, {38, 4}, {26, 22}}), Line(points = {{20, 4}, {32, 4}}, color = {0, 0, 255}), Polygon(lineColor = {0, 0, 255}, points = {{22, -20}, {30, -20}, {26, -32}, {22, -20}}), Text(lineColor = {0, 0, 255}, extent = {{-100, 150}, {100, 110}}, textString = "%name"), Text(origin = {-53, -1}, lineColor = {238, 46, 47}, extent = {{-3, 3}, {9, -13}}, textString = "E", fontName = "Times New Roman"), Text(origin = {-25, 83}, lineColor = {238, 46, 47}, extent = {{-3, 3}, {9, -13}}, textString = "R1", fontName = "Times New Roman"), Text(origin = {-23, 29}, lineColor = {238, 46, 47}, extent = {{-3, 3}, {9, -13}}, textString = "C1", fontName = "Times New Roman"), Text(origin = {47, 9}, lineColor = {238, 46, 47}, extent = {{-3, 3}, {9, -13}}, textString = "Ip", fontName = "Times New Roman"), Text(origin = {51, 83}, lineColor = {238, 46, 47}, extent = {{-3, 3}, {9, -13}}, textString = "R0", fontName = "Times New Roman")}));
      end Batt1;

      model Batt1Conn "Battery model based on Batt0 but with electric dynamics order = 1"
        Modelica.SIunits.Power powDeliv "battery power (positive when delivered)";
        Real SOC "State Of Charge";
        parameter Modelica.SIunits.ElectricCharge QCellNom(min = 0) = 10 * 3.6e3 "Nominal admissible electric charge per cell" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Voltage ECellMin(min = 0) = 3.3 "Minimum open source voltage per cell" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Voltage ECellMax(min = 0.0001) = 4.15 "Maximum open source voltage per cell" annotation (
          Dialog(tab = "Cell data"));
        parameter Real SOCMin(min = 0, max = 1) = 0 "Minimum state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Real SOCMax(min = 0, max = 1) = 1 "Maximum state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Real SOCInit(min = 0, max = 1) = 0.5 "Initial state of charge" annotation (
          Dialog(group = "SOC parameters"));
        parameter Modelica.SIunits.Current ICellMax(min = 0) = 10 * QCellNom / 3.6e3 "Maximum admissible current" annotation (
          Dialog(tab = "Cell data"));
        parameter Modelica.SIunits.Resistance R0Cell(min = 0) = 0.05 * ECellMax / ICellMax "Series resistance \"R0\"" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Modelica.SIunits.Resistance R1Cell(min = 0) = R0Cell "Series resistance \"R1\"" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Modelica.SIunits.Capacitance C1Cell(min = 0) = 60 / R1Cell "Capacitance in parallel with R1" annotation (
          Dialog(tab = "Cell data", group = "Electric circuit parameters"));
        parameter Real efficiency(min = 0, max = 0.9999) = 0.85 "Overall charging/discharging energy efficiency" annotation (
          Dialog(group = "Parameters related to losses"));
        parameter Modelica.SIunits.Current iCellEfficiency(min = 0) = 0.5 * ICellMax "Cell charging/discharging current the efficiency refers to" annotation (
          Dialog(group = "Parameters related to losses"));
        parameter Integer ns = 1 "Number of serial connected cells" annotation (
          Dialog(tab = "Battery Pack data", group = "Size of the package"));
        parameter Integer np = 1 "Number of parallel connected cells" annotation (
          Dialog(tab = "Battery Pack data", group = "Size of the package"));
        Modelica.SIunits.Voltage uBat(start = eBattMin + SOCInit * (eBattMax - eBattMin), fixed = true);
        // determine fraction of drain current with respect to the total package current
        Modelica.Electrical.Analog.Basic.Capacitor cBattery(final C = CBattery) annotation (
          Placement(transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Electrical.Analog.Basic.Resistor R0(final R = R0Battery) annotation (
          Placement(transformation(origin = {20, 60}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Analog.Sources.SignalCurrent Ip annotation (
          Placement(transformation(origin = {-6, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Electrical.Analog.Interfaces.Pin p annotation (
          Placement(transformation(extent = {{90, 50}, {110, 70}}), iconTransformation(extent = {{90, 52}, {110, 72}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (
          Placement(transformation(extent = {{90, -70}, {110, -50}}), iconTransformation(extent = {{91, -70}, {111, -50}})));
        Modelica.Electrical.Analog.Basic.Capacitor C1(C = C1Battery) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 180, origin = {-37, 50})));
        EHPTlib.SupportModels.ConnectorRelated.Conn conn annotation (Placement(
              transformation(
              extent={{-20,-20},{20,20}},
              rotation=90,
              origin={-100,-2})));
        Modelica.Blocks.Sources.RealExpression SOCs(y = SOC) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {-80, 30})));
        Modelica.Blocks.Sources.RealExpression outPow(y = (p.v - n.v) * n.i) annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = -90, origin = {-80, -26})));
        Modelica.Electrical.Analog.Basic.Resistor R1(final R = R1Battery) annotation (
          Placement(visible = true, transformation(origin = {-37, 72}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
      protected
        parameter Real k = ((1 - efficiency) * (eBattMax + eBattMin) - 2 * (1 + efficiency) * Rtot * iCellEfficiency) / ((1 + efficiency) * (eBattMax + eBattMin) - 2 * (1 - efficiency) * Rtot * iCellEfficiency);
        parameter Real efficiencyMax = (eBattMin + eBattMax - 2 * Rtot * iCellEfficiency) / (eBattMin + eBattMax + 2 * Rtot * iCellEfficiency);
        final parameter Modelica.SIunits.Capacitance C = QCellNom / (ECellMax - ECellMin) "Cell capacitance";
        parameter Modelica.SIunits.Current IBatteryMax = ICellMax * np "Maximum battery current";
        parameter Modelica.SIunits.Voltage eBattMin = ECellMin * ns "Minimum battery voltage";
        parameter Modelica.SIunits.Voltage eBattMax = ECellMax * ns "Maximum battery voltage";
        parameter Modelica.SIunits.ElectricCharge QBatteryNominal = QCellNom * np "Battery admissible electric charge";
        parameter Modelica.SIunits.Capacitance CBattery = C * np / ns "Battery capacitance";
        parameter Modelica.SIunits.Resistance R0Battery = R0Cell * ns / np "Series inner resistance R0 of cell package";
        parameter Modelica.SIunits.Resistance R1Battery = R1Cell * ns / np "Series inner resistance R1 of cell package";
        parameter Modelica.SIunits.Resistance Rtot = R0Battery + R1Battery;
        parameter Modelica.SIunits.Capacitance C1Battery = C1Cell * np / ns "Battery series inner capacitance C1";
        Modelica.SIunits.Voltage ECell "Cell e.m.f.";
        Modelica.SIunits.Current iCellStray "Cell stray current";
        Modelica.SIunits.Voltage eBatt(start = eBattMin + SOCInit * (eBattMax - eBattMin), fixed = true) "Battery e.m.f.";
        Modelica.SIunits.Current iBatteryStray "Cell parasitic current";
        Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation (
          Placement(transformation(extent = {{70, 50}, {90, 70}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = k) annotation (
          Placement(transformation(origin = {60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Blocks.Math.Abs abs1 annotation (
          Placement(transformation(extent = {{34, -10}, {14, 10}}, rotation = 0)));
      equation
        connect(R1.p, R0.n) annotation (
          Line(points = {{-27, 72}, {-18, 72}, {-18, 60}, {10, 60}}, color = {0, 0, 255}));
        connect(R1.p, C1.p) annotation (
          Line(points = {{-27, 72}, {-18, 72}, {-18, 50}, {-27, 50}}, color = {0, 0, 255}));
        connect(R1.n, cBattery.p) annotation (
          Line(points = {{-47, 72}, {-60, 72}, {-60, 10}}, color = {0, 0, 255}));
        assert(SOCMin >= 0, "SOCMin must be greater than, or equal to 0");
        assert(SOCMax <= 1, "SOCMax must be smaller than, or equal to 1");
        assert(efficiency <= efficiencyMax, "Overall charging/discharging energy efficiency is too big with respect to the actual serial resistance (EfficiencyMax =" + String(efficiencyMax) + ")");
        assert(SOCMin < SOCMax, "SOCMax(=" + String(SOCMax) + ") must be greater than SOCMin(=" + String(SOCMin) + ")");
        assert(SOCInit >= SOCMin, "SOCInit(=" + String(SOCInit) + ") must be greater than, or equal to SOCMin(=" + String(SOCMin) + ")");
        assert(SOCInit <= SOCMax, "SOCInit(=" + String(SOCInit) + ") must be smaller than, or equal to SOCMax(=" + String(SOCMax) + ")");
        iBatteryStray = Ip.i;
        iCellStray = iBatteryStray / np;
        uBat = p.v - n.v;
        eBatt = cBattery.v;
        //Solo per dare maggiore chiarezza all'utente con un nome significativo
        ECell = eBatt / ns;
        powDeliv = (p.v - n.v) * n.i;
        assert(abs(p.i / np) < ICellMax, "Battery cell current i=" + String(abs(p.i / np)) + "\n exceeds max admissable ICellMax (=" + String(ICellMax) + "A)");
        SOC = (eBatt - eBattMin) / (eBattMax - eBattMin);
        //*(SOCMax-SOCMin)+SOCMin);
        assert(SOC <= SOCMax, "Battery is fully charged: State of charge reached maximum limit (=" + String(SOCMax) + ")");
        assert(SOCMin <= SOC, "Battery is fully discharged: State of charge reached minimum limit (=" + String(SOCMin) + ")");
        connect(R0.p, currentSensor.p) annotation (
          Line(points = {{30, 60}, {70, 60}}, color = {0, 0, 255}));
        connect(Ip.p, R0.n) annotation (
          Line(points = {{-6, 10}, {-6, 60}, {10, 60}}, color = {0, 0, 255}));
        connect(currentSensor.i, gain.u) annotation (
          Line(points = {{80, 50}, {80, -1.46958e-015}, {72, -1.46958e-015}}, color = {0, 0, 127}));
        connect(abs1.u, gain.y) annotation (
          Line(points = {{36, 0}, {39.5, 0}, {39.5, 1.33227e-015}, {49, 1.33227e-015}}, color = {0, 0, 127}));
        connect(abs1.y, Ip.i) annotation (
          Line(points = {{13, 0}, {7, 0}, {7, -1.28588e-015}, {1, -1.28588e-015}}, color = {0, 0, 127}));
        connect(currentSensor.n, p) annotation (
          Line(points = {{90, 60}, {90, 60}, {100, 60}}, color = {0, 0, 255}));
        connect(Ip.n, n) annotation (
          Line(points = {{-6, -10}, {-6, -60}, {100, -60}}, color = {0, 0, 255}));
        connect(n, cBattery.n) annotation (
          Line(points = {{100, -60}, {-60, -60}, {-60, -10}}, color = {0, 0, 255}));
        connect(C1.n, cBattery.p) annotation (
          Line(points = {{-47, 50}, {-60, 50}, {-60, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(conn.batSOC, SOCs.y) annotation (
          Line(points = {{-100, -2}, {-100, 8.5}, {-80, 8.5}, {-80, 19}}, color = {255, 204, 51}, thickness = 0.5, smooth = Smooth.None),
          Text(string = "%first", index = -1, extent = {{-6, 3}, {-6, 3}}));
        connect(outPow.y, conn.batPowDel) annotation (
          Line(points = {{-80, -15}, {-80, -2}, {-100, -2}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Documentation(info = "<html>
<p>Battery model with non-unity coulombic efficiency. </p>
<p>The main cell branch contains an e.m.f. that is linearly increasing with SOC, simulated through an equivalent capacitor, the resistance R0 and a parallel R-C couple. </p>
<p>The full battery is composed by np rows in parallel, each of them containing ns cells in series.</p>
<p>It interfaces with monitoring systems tohrough an expandable connector. Output signals:</p>
<p>- state-of-charge &QUOT;batSOC&QUOT;</p>
<p>- outputted power &QUOT;batPowDel&QUOT;.</p>
</html>", revisions = "<html><table border=\"1\" rules=\"groups\">
    <thead>
    <tr><td>Version</td>  <td>Date</td>  <td>Comment</td></tr>
    </thead>
    <tbody>
    <tr><td>1.0.0</td>  <td>2006-01-12</td>  <td> </td></tr>
    <tr><td>1.0.3</td>  <td>2006-08-31</td>  <td> Improved assert statements </td></tr>
    <tr><td>1.0.6</td>  <td>2007-05-14</td>  <td> The documentation changed slightly </td></tr>
    </tbody>
    </table>
    </html>"),
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics),
          Icon(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(lineColor = {95, 95, 95}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 80}, {80, -82}}), Line(points = {{-92, 6}, {-52, 6}}, color = {0, 0, 255}), Rectangle(lineColor = {0, 0, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Solid, extent = {{-82, -3}, {-65, -10}}), Line(points = {{-73, 63}, {98, 64}}, color = {0, 0, 255}), Rectangle(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{38, 69}, {68, 57}}), Rectangle(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-37.5, 68}, {-6.5, 56}}), Line(points = {{-19.5, 49}, {-19.5, 32}}, color = {0, 0, 255}), Line(points = {{-54.5, 63}, {-54.5, 41}, {-25.5, 41}}, color = {0, 0, 255}), Line(points = {{9.5, 62}, {9.5, 40}, {-19.5, 40}}, color = {0, 0, 255}), Line(points = {{-73, 63}, {-73, 5}}, color = {0, 0, 255}), Line(points = {{-73, -6}, {-73, -60}, {96, -60}}, color = {0, 0, 255}), Line(points = {{26, 63}, {26, -61}}, color = {0, 0, 255}), Line(points = {{-25.5, 49}, {-25.5, 32}}, color = {0, 0, 255}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, points = {{26, 22}, {14, 4}, {26, -14}, {38, 4}, {26, 22}}), Line(points = {{20, 4}, {32, 4}}, color = {0, 0, 255}), Polygon(lineColor = {0, 0, 255}, points = {{22, -20}, {30, -20}, {26, -32}, {22, -20}}), Text(origin = {-4, -22}, lineColor = {0, 0, 255}, extent = {{-100, 150}, {100, 110}}, textString = "%name")}));
      end Batt1Conn;

      model DragForceAngle "Vehicle rolling and aerodinamical drag force"
        import Modelica.Constants.g_n;
        extends
          Modelica.Mechanics.Translational.Interfaces.PartialElementaryOneFlangeAndSupport2;
        extends Modelica.Mechanics.Translational.Interfaces.PartialFriction;
        parameter Modelica.SIunits.Mass m "vehicle mass";
        parameter Modelica.SIunits.Density rho(start = 1.226) "air density";
        parameter Modelica.SIunits.Area S "vehicle cross area";
        parameter Real fc(start = 0.01) "rolling friction coefficient";
        parameter Real Cx "aerodinamic drag coefficient";
        Modelica.SIunits.Force dragForce "Total drag force";
        Modelica.SIunits.Velocity v "vehicle velocity";
        Modelica.SIunits.Acceleration a "Absolute acceleration of flange";
        parameter String DataFileName = "DataName.txt" "Name of file with angles function of s (rad) ex: \"Angle.txt\"";
        final parameter Real A = fc * m * g_n;
        final parameter Real A1 = m * g_n;
        final parameter Real B = 1 / 2 * rho * S * Cx;
        final parameter Real mu[:, 2] = [0, 1];
        Real angle = sToAngle.y[1], Sign;
        Modelica.SIunits.Length altimetry;
        Real debug = dragForce - B * v ^ 2 * Sign;
        // Constant auxiliary variable
        Modelica.Blocks.Tables.CombiTable1Ds sToAngle(tableOnFile = true, fileName = DataFileName, tableName = "Angle") annotation (
          Placement(transformation(extent = {{28, -10}, {8, 10}})));
      equation
        der(altimetry) = v * sin(sToAngle.y[1]);
        // Let us connect the table which determines angles:
        sToAngle.u = flange.s;
        //  s = flange.s;
        v = der(s);
        a = der(v);
        // Le seguenti definizioni seguono l'ordine e le richieste del modello "PartialFriction" di
        // Modelica.Mechanics.Translational.Interfaces"
        v_relfric = v;
        a_relfric = a;
        f0 = A * cos(angle) + A1 * sin(angle) "Friction force for v_relfric=0 and forward sliding";
        f0_max = A "Maximum friction force for v_relfric=0 and locked";
        free = false "true when there is not wheel-road contact (never!)";
        // Ora il calcolo di dragForce, e la sua attribuzione alla flangia:
        flange.f - dragForce = 0;
        // friction force
        if v > 0 then
          Sign = 1;
        else
          Sign = -1;
        end if;
        //La seguente equzione uguaglia la  dragForce alla forza applicata se siamo in locked, altrimenti al termine A
        dragForce - B * v ^ 2 * Sign = if locked then sa * unitForce else f0 * (if startForward then Modelica.Math.Vectors.interpolate(mu[:, 1], mu[:, 2], v) else if startBackward then -Modelica.Math.Vectors.interpolate(mu[:, 1], mu[:, 2], -v) else if pre(mode) == Forward then Modelica.Math.Vectors.interpolate(mu[:, 1], mu[:, 2], v) else -Modelica.Math.Vectors.interpolate(mu[:, 1], mu[:, 2], -v));
        annotation (
          Documentation(info = "<html>
            <p>This component modesl the total (rolling and aerodynamic vehicle drag resistance: </p>
            <p>F=fc*m*g+(1/2)*rho*Cx*S*v^2</p>
            <p>It models reliably the stuck phase. Based on Modelica-Intrerfaces.PartialFriction model</p>
            </html>"),
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Polygon(points = {{-98, 10}, {22, 10}, {22, 41}, {92, 0}, {22, -41}, {22, -10}, {-98, -10}, {-98, 10}}, lineColor = {0, 127, 0}, fillColor = {215, 215, 215}, fillPattern = FillPattern.Solid), Line(points = {{-90, -90}, {-70, -88}, {-50, -82}, {-30, -72}, {-10, -58}, {10, -40}, {30, -18}, {50, 8}, {70, 38}, {90, 72}}, color = {0, 0, 255}, thickness = 0.5), Text(extent = {{-82, 90}, {80, 50}}, lineColor = {0, 0, 255}, textString = "%name"), Line(points = {{32, 48}, {-62, -38}, {64, -40}}, color = {238, 46, 47}, thickness = 0.5), Polygon(points = {{-20, 0}, {-8, -10}, {0, -26}, {2, -38}, {-62, -38}, {-20, 0}}, lineColor = {238, 46, 47}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid)}),
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 60}}), graphics = {Text(extent = {{-58, -30}, {68, -48}}, lineColor = {0, 0, 0}, lineThickness = 0.5, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, textString = "Connections of sToAngle made internally")}));
      end DragForceAngle;

      model AronSensor "Two port three-phase power sensor"
        Modelica.Electrical.MultiPhase.Interfaces.PositivePlug pc "Positive plug, current path" annotation (
          Placement(transformation(extent = {{-110, -10}, {-90, 10}}), iconTransformation(extent = {{-110, -10}, {-90, 10}})));
        Modelica.Electrical.MultiPhase.Interfaces.NegativePlug nc(final m = 3) "Negative plug, current path" annotation (
          Placement(transformation(extent = {{90, 12}, {110, -8}}, rotation = 0), iconTransformation(extent = {{90, 10}, {110, -10}})));
        Modelica.Blocks.Interfaces.RealOutput y(final unit = "W") annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {-20, -110})));
      equation
        for ph in 1:3 loop
          pc.pin[ph].i + nc.pin[ph].i = 0;
          pc.pin[ph].v = nc.pin[ph].v;
        end for;
        //Aron formula for power (common wire is wire 2):
        y = pc.pin[1].i * (pc.pin[1].v - pc.pin[2].v) + pc.pin[3].i * (pc.pin[3].v - pc.pin[2].v);
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Line(points = {{-104, 0}, {96, 0}}, color = {0, 0, 255}), Ellipse(extent = {{-70, 70}, {70, -70}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{0, 70}, {0, 40}}, color = {0, 0, 0}), Line(points = {{22.9, 32.8}, {40.2, 57.3}}, color = {0, 0, 0}), Line(points = {{-22.9, 32.8}, {-40.2, 57.3}}, color = {0, 0, 0}), Line(points = {{37.6, 13.7}, {65.8, 23.9}}, color = {0, 0, 0}), Line(points = {{-37.6, 13.7}, {-65.8, 23.9}}, color = {0, 0, 0}), Line(points = {{0, 0}, {9.02, 28.6}}, color = {0, 0, 0}), Polygon(points = {{-0.48, 31.6}, {18, 26}, {18, 57.2}, {-0.48, 31.6}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0}, fillPattern = FillPattern.Solid), Ellipse(extent = {{-5, 5}, {5, -5}}, lineColor = {0, 0, 0}, fillColor = {0, 0, 0}, fillPattern = FillPattern.Solid), Text(extent = {{-39, -3}, {40, -66}}, lineColor = {0, 0, 0}, textString = "P3"), Line(points = {{-20, -104}, {-20, -66}}, color = {0, 0, 127}, smooth = Smooth.None), Text(origin = {0, 10}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 102}, {100, 62}}, textString = "%name")}),
          Documentation(info = "<html>
<p><code><span style=\"font-family: Courier New,courier;\">&nbsp;Uses the <span style=\"color: #006400;\">Aron&nbsp;formula&nbsp;for&nbsp;power&nbsp;(common&nbsp;wire&nbsp;is&nbsp;wire&nbsp;2):</span></code></p>
<pre><span style=\"font-family: Courier New,courier; color: #006400;\">y=i1*(v1-v2) + i3*(v3-v2)</span></pre>
</html>"));
      end AronSensor;
    end Miscellaneous;

    package ConnectorRelated
      model ToConnIceTauRef "Signal adaptor to send iceTauRef to a connector"
        Modelica.Blocks.Interfaces.RealInput u annotation (
          Placement(transformation(extent = {{-94, -20}, {-54, 20}}), iconTransformation(extent = {{-94, -20}, {-54, 20}})));
        Conn conn annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {60, 0}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {60, 0})));
      equation
        connect(u, conn.iceTauRef) annotation (
          Line(points = {{-74, 0}, {60, 0}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}}), graphics = {Rectangle(extent = {{-60, 40}, {60, -40}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-38, 0}, {30, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{42, 0}, {22, 8}, {22, -8}, {42, 0}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {0, 0, 0}, fillPattern = FillPattern.Solid)}),
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}}), graphics),
          Documentation(info = "<html>
<p><span style=\"font-family: MS Shell Dlg 2;\">Adapter for an input signal into &QUOT;iceTauRef&QUOT; signal in the library connector.</span></p>
</html>"));
      end ToConnIceTauRef;

      model ToConnGenTauRef "Signal adaptor to send genTauRef to a connector"
        Modelica.Blocks.Interfaces.RealInput u annotation (
          Placement(transformation(extent = {{-90, -20}, {-50, 20}}), iconTransformation(extent = {{-90, -20}, {-50, 20}})));
        Conn conn annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {58, 0}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {58, 0})));
      equation
        connect(u, conn.genTauRef) annotation (
          Line(points = {{-70, 0}, {58, 0}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}}), graphics = {Rectangle(extent = {{-60, 40}, {60, -40}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-40, 0}, {32, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{42, 0}, {22, 8}, {22, -8}, {42, 0}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {0, 0, 0}, fillPattern = FillPattern.Solid)}),
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}}), graphics),
          Documentation(info = "<html>
<p><span style=\"font-family: MS Shell Dlg 2;\">Adapter for an input signal into &QUOT;genTauRef&QUOT; signal in the library connector.</span></p>
</html>"));
      end ToConnGenTauRef;

      model ToConnIcePowRef "Signal adaptor to send icePowRef to a connector"
        Modelica.Blocks.Interfaces.RealInput u annotation (
          Placement(transformation(extent = {{-94, -20}, {-54, 20}}), iconTransformation(extent = {{-94, -20}, {-54, 20}})));
        Conn conn annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {60, 0}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {60, 0})));
      equation
        connect(u, conn.icePowRef) annotation (
          Line(points = {{-74, 0}, {60, 0}, {60, 0}}, color = {0, 0, 127}),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}}), graphics = {Rectangle(extent = {{-60, 40}, {60, -40}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-38, 0}, {30, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{42, 0}, {22, 8}, {22, -8}, {42, 0}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {0, 0, 0}, fillPattern = FillPattern.Solid)}),
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {60, 60}})),
          Documentation(info = "<html>
<p><span style=\"font-family: MS Shell Dlg 2;\">Adapter for an input signal into &QUOT;icePowRef&QUOT; signal in the library connector.</span></p>
</html>"));
      end ToConnIcePowRef;

      expandable connector Conn "Control bus that is adapted to the signals connected to it"
        extends Modelica.Icons.SignalBus;
        annotation (
          Diagram(graphics));
      end Conn;
    end ConnectorRelated;
    annotation (
      Icon(graphics={  Ellipse(extent = {{-36, 40}, {40, -36}}, lineColor = {0, 0, 0}), Line(points = {{4, 82}, {-6, 82}, {-10, 72}, {-24, 68}, {-34, 78}, {-46, 70}, {-42, 58}, {-54, 46}, {-66, 50}, {-74, 36}, {-66, 30}, {-68, 16}, {-78, 12}, {-78, 2}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{4, -78}, {-6, -78}, {-10, -68}, {-24, -64}, {-34, -74}, {-46, -66}, {-42, -54}, {-54, -42}, {-66, -46}, {-74, -32}, {-66, -26}, {-68, -12}, {-78, -8}, {-78, 2}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{2, -78}, {12, -78}, {16, -68}, {30, -64}, {40, -74}, {52, -66}, {48, -54}, {60, -42}, {72, -46}, {80, -32}, {72, -26}, {74, -12}, {84, -8}, {84, 2}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{2, 82}, {12, 82}, {16, 72}, {30, 68}, {40, 78}, {52, 70}, {48, 58}, {60, 46}, {72, 50}, {80, 36}, {72, 30}, {74, 16}, {84, 12}, {84, 2}}, color = {0, 0, 0}, smooth = Smooth.None)}));
  end SupportModels;

  //Symbol to force Dymola to use UTF: €
  //package Propulsion
  extends Modelica.Icons.Package;
  //end Propulsion;

  package MapBased "Contains map-based models of Internal combustion engines and electric drives"
    extends Modelica.Icons.Package;

    class Information
      extends Modelica.Icons.Information;
      annotation (
        Documentation(info = "<html>
<p>The map-based folder contains simple model whose only dynamics is due to their mechanical inertia.</p>
<p>The ice model, since implements an Internal Combustion Engine, can just deliver (never absorb) power, while the other two (&QUOT;oneFlange&QUOT; and &QUOT;twoFlange&QUOT;) simulate electric drive trains, i.e. the assembly of an electric machine and the corresponding AC/DC converter, and therefore can absorb or deliver power.</p>
<p>The input torque of the ice model is in Newton-metres, while in the other cases it is normalised: it is between -1 and +1, where -1 means maximum available torque to be absorbed, +1 to be delivered.</p>
<p>Some of the models have a special &QUOT;Conn&QUOT; version that allows interfacing with the exterior by means of an expandable connector.</p>
<p>Note that usage of expandable connectors requires to give special names to the connector&apos;s variables, and therefore the models are more specific than their Modelica.Blocks.Connectors counterparts. Therefore here the models have receives specifi names such as &QUOT;PsdGenConn&QUOT; as a replacement of OneFlange: this is aone flance component to which we added a connector and spfcific signal names.</p>
<p><br><u>Names and meaning </u>of the pre-defined quantities circulating through the connection bus in the model versions having &QUOT;Conn&QUOT; in their names.</p>
<p>The detailed meaning of different quantities are to be read in the corresponding Table in the accompanying document &QUOT;webBookCeraolo&QUOT; in its section PSD-HEV.</p>
</html>"),
        uses(Modelica(version = "3.2.1")));
    end Information;

    model IceT "Simple  map-based ice model with connector"
      import Modelica.Constants.*;
      extends Partial.PartialIce;
      parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
      // rad/s
      Modelica.Blocks.Interfaces.RealInput tauRef "torque request (positive when motor)" annotation (
        Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {-60, -100}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {-60, -100})));
      Modelica.Blocks.Interfaces.RealOutput fuelCons "Fuel consumption (g/h)" annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {60, -90})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMin = 0, uMax = 1e99) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-60, -16})));
      Modelica.Blocks.Math.Min min annotation (
        Placement(transformation(extent = {{-48, 50}, {-28, 70}})));
    equation
      connect(toG_perHour.y, fuelCons) annotation (
        Line(points = {{30, -61}, {30, -61}, {26, -61}, {60, -61}, {60, -90}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(limiter.u, tauRef) annotation (
        Line(points = {{-60, -28}, {-60, -100}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(min.u1, toLimTau.y[1]) annotation (
        Line(points = {{-50, 66}, {-58, 66}, {-61, 66}}, color = {0, 0, 127}));
      connect(min.u2, limiter.y) annotation (
        Line(points = {{-50, 54}, {-60, 54}, {-60, -5}}, color = {0, 0, 127}));
      connect(min.y, Tice.tau) annotation (
        Line(points = {{-27, 60}, {-21.5, 60}, {-14, 60}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
        experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p>This model belongs to the map-based models of power train components.</p>
<p>It models an Internal Combustion Engine, neglecting any dynamics except that related with its rotor inertia.</p>
<p>The input signal is the torque request (Nm). </p>
<p>The generated torque is the minimum between this signal (negative values are transformed to 0) and the maximum deliverable torque at the actual engine speed, defined by means of a table.</p>
<p>From the generated torque and speed the fuel consumption is computed.</p>
<p>Compare ICE input tau and internal Tice.tau.</p>
</html>"),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-100, -44}, {-22, -72}}, lineColor = {0, 0, 127}, textString = "Nm")}));
    end IceT;

    model IceT01 "Simple  map-based ice model with connector"
      import Modelica.Constants.*;
      extends Partial.PartialIce(toLimTau(table = maxIceTau, tableOnFile = tablesOnFile, tableName = "maxIceTau", fileName = mapsFileName), toSpecCons(tableOnFile = tablesOnFile, fileName = mapsFileName, tableName = "specificCons"));
      Modelica.Blocks.Interfaces.RealInput nTauRef "normalized torque request" annotation (
        Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {-60, -100}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {-60, -100})));
      Modelica.Blocks.Interfaces.RealOutput fuelCons "Fuel consumption (g/h)" annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {60, -90})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMin = 0, uMax = 1) annotation (
        Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-60, -16})));
      Modelica.Blocks.Math.Product product annotation (
        Placement(transformation(extent = {{-48, 50}, {-28, 70}})));
    equation
      connect(toG_perHour.y, fuelCons) annotation (
        Line(points = {{30, -61}, {30, -62}, {30, -62}, {30, -62}, {30, -70}, {60, -70}, {60, -90}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(limiter.u, nTauRef) annotation (
        Line(points = {{-60, -28}, {-60, -100}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(Tice.tau, product.y) annotation (
        Line(points = {{-14, 60}, {-27, 60}}, color = {0, 0, 127}));
      connect(product.u2, limiter.y) annotation (
        Line(points = {{-50, 54}, {-60, 54}, {-60, 52}, {-60, -5}}, color = {0, 0, 127}));
      connect(product.u1, toLimTau.y[1]) annotation (
        Line(points = {{-50, 66}, {-58, 66}, {-58, 66}, {-61, 66}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
        experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p>This model belongs to the map-based models of power train components.</p>
<p>It models an Internal Combustion Engine, neglecting any dynamics except that related with its rotor inertia.</p>
<p>The input signal is a normalised request (0..1). </p>
<p>The generated torque is the product of the maximum deliverable torque at the actual engine speed, defined by means of a table, and the normalised input signal</p>
<p>From the generated torque and speed the fuel consumption is computed.</p>
</html>"),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-100, -40}, {-20, -70}}, lineColor = {0, 0, 127}, textString = "0..1")}));
    end IceT01;

    model OneFlange "Simple map-based model of an electric drive"
      extends Partial.PartialOneFlange;
      Modelica.Blocks.Interfaces.RealInput tauRef "(positive when motor peration)" annotation (
        Placement(visible = true, transformation(origin = {-118, -66}, extent = {{-18, -18}, {18, 18}}, rotation = 0), iconTransformation(origin = {-114, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    equation
      connect(variableLimiter.u, tauRef) annotation (
        Line(points = {{-2, 30}, {14, 30}, {14, -66}, {-118, -66}}, color = {0, 0, 127}));
      annotation (
        Documentation(info = "<html>
<p>This is a model that models an electric drive: electornic converter + electric machine.</p>
<p>The only model dynamics is its inertia. </p>
<p>The input signal is a torque request (Nm). The requested torque is applied to a mechanical inertia. </p>
<p>The maximum available torque is internally computed considering a direct torque maximum (tauMax) and a power maximum (powMax) </p>
<p>The model then computes the inner losses and absorbs the total power from the DC input.</p>
<p>Note that to evaluate the inner losses the model uses an efficiency map (i.e. a table), in which torques are ratios of actual torques to tauMax and speeds are ratios of w to wMax. Because of this wMax must be supplied as a parameter.</p>
</html>"),
        Diagram(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1)),
        Icon(coordinateSystem(extent = {{-100, -80}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1)));
    end OneFlange;

    model OneFlange2 "Simple map-based model of an electric drive"
      extends Partial.PartialOneFlange2;
      Modelica.Blocks.Interfaces.RealInput tauRef "(positive when motor peration)" annotation (
        Placement(visible = true, transformation(origin = {-118, -66}, extent = {{-18, -18}, {18, 18}}, rotation = 0), iconTransformation(origin = {-114, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
    equation
      connect(variableLimiter.u, tauRef) annotation (
        Line(points = {{-2, 30}, {14, 30}, {14, -66}, {-118, -66}}, color = {0, 0, 127}));
      annotation (
        Documentation(info = "<html><head></head><body><p>This is a model that models an electric drive: electornic converter + electric machine.</p>
<p>The only model dynamics is its inertia. </p>
<p>The input signal is a torque request (Nm). The requested torque is applied to a mechanical inertia. </p>
<p>The maximum available torque is internally computed considering a direct torque maximum (tauMax) and a power maximum (powMax) </p>
<p>The model then computes the inner losses and absorbs the total power from the DC input.</p>
<p>Note that to evaluate the inner losses the model uses an efficiency map (i.e. a table), in which torques are ratios of actual torques to tauMax and speeds are ratios of w to wMax. Because of this wMax must be supplied as a parameter.</p>
<p>Improvement onto OneFlange: now the user can implement max and minimum torque as a function of the angular speed, through curves supplied via an array taken from an input file.</p>
<p>This model is not parameter-compatible with OneFlange. This has caused this new model to be introduced. </p>
</body></html>"),
        Diagram(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1)),
        Icon(coordinateSystem(extent = {{-100, -80}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1)));
    end OneFlange2;

    model TwoFlange "Simple map-based two-flange electric drive model"
      extends Partial.PartialTwoFlange;
      Modelica.Blocks.Interfaces.RealInput tauRef annotation (
        Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {0, -114}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {0, -92})));
    equation
      connect(tauRef, limTau.tau) annotation (
        Line(points = {{0, -114}, {0, -114}, {0, -60}, {0, -58}, {-60, -58}, {-60, -9.6}, {-54.2, -9.6}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-100, 10}, {-66, -10}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{66, 8}, {100, -12}}), Rectangle(origin = {-25, 2}, extent = {{-75, 74}, {125, -74}}), Line(origin = {20, -2}, points = {{-60, 94}, {-60, 76}}, color = {0, 0, 255}), Line(origin = {-20, -2}, points = {{60, 94}, {60, 76}}, color = {0, 0, 255})}),
        Documentation(info = "<html>
<p>This is a model that models an electric drive: electornic converter + electric machine.</p>
<p>The only model dynamics is its inertia. </p>
<p>The input signal is a torque request (Nm). The requested torque is applied to a mechanical inertia. </p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The model receives from the input connector the torque request and tries to &QUOT;deliver&QUOT; it. Delivering means adding a torque to the system so that the torque exiting from flange B equals the one entering from flange A plus the one requested from the input connector.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This simulates a two-flange electrical machine, where the added torque is the torque produced by the machine magnetic field stator-rotor interaction.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">However, before delivering the requested torque, the model limits it considering the maximum deliverable torque and power. In addition, it computes and considers inner losses as determined by means of a map. </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The maximum available torque is internally computed considering a direct torque maximum (tauMax) and a power maximum (powMax) </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The requested torque is applied to a mechancal inertia. The inertia is interfaced by means of two flanges with the exterior.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">The model then computes the inner losses and absorbs the total power from the DC input.</span></p>
</html>"));
    end TwoFlange;

    model TwoFlangeConn "Simple map-based two-flange electric drive model"
      import wbEHPTlib =
             EHPTlib;
      extends wbEHPTlib.MapBased.Partial.PartialTwoFlange;
      SupportModels.ConnectorRelated.Conn conn1 annotation (
        Placement(visible = true, transformation(extent = {{-112, -58}, {-72, -98}}, rotation = 0), iconTransformation(extent = {{-112, -58}, {-72, -98}}, rotation = 0)));
    equation
      connect(outBPow_.power, conn1.motPowDelB) annotation (
        Line(points = {{64, 39}, {64, -78}, {-92, -78}, {-92, -78}}, color = {0, 0, 127}, smooth = Smooth.None),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(speedRing.w, conn1.motW) annotation (
        Line(points = {{-80, 29}, {-86, 29}, {-86, 28}, {-92, 28}, {-92, -78}}, color = {0, 0, 127}, smooth = Smooth.None),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(add.y, conn1.motPowDelAB) annotation (
        Line(points = {{32, -1}, {32, -22}, {78, -22}, {78, -78}, {-92, -78}}, color = {0, 0, 127}, smooth = Smooth.None),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(torqueLimiter.u, conn1.motTauRef) annotation (
        Line(points = {{-18, 2}, {-26, 2}, {-26, -56}, {-92, -56}, {-92, -78}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-100, 10}, {-66, -10}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{66, 8}, {100, -12}}), Rectangle(origin = {-25, 2}, extent = {{-75, 74}, {125, -74}}), Line(origin = {20, -2}, points = {{-60, 94}, {-60, 76}}, color = {0, 0, 255}), Line(origin = {-20, -2}, points = {{60, 94}, {60, 76}}, color = {0, 0, 255})}),
        Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Simple map-based ICE model for power-split power trains - with connector</b> </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This is a &QUOT;connector&QUOT; version of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">For a general descritiption see the info of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Signals connected to the connector:</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowRef (input) is the power request (W). Negative values are internally converted to zero</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- iceW (output) is the measured ICE speed (rad/s)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowDel (output) delivered power (W)</span></p>
</html>"));
    end TwoFlangeConn;

    model Genset "GenSet GMS+GEN+SEngine"
      import Modelica.Constants.inf;
      import Modelica.Constants.pi;
      parameter Real gsRatio = 2 "IdealGear speed reduction factor";
      parameter String mapsFileName = "maps.txt" "File containing data maps (maxIceTau, gensetDriveEffTable, specificCons, optiSpeed)";
      parameter Modelica.SIunits.AngularVelocity maxGenW = 1e6 "Max generator angular speed";
      parameter Modelica.SIunits.Torque maxTau = 200 "Max mechanical torque between internal ICE and generator";
      parameter Modelica.SIunits.Power maxPow = 20e3 "Max mechanical of the internal generator";
      parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 180, origin = {-24, -20})));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor IcePow annotation (
        Placement(transformation(extent = {{24, -2}, {42, 16}})));
      Modelica.Blocks.Interfaces.RealInput powRef(unit = "W") "Reference genset power" annotation (
        Placement(transformation(extent = {{15, -15}, {-15, 15}}, rotation = 90, origin = {61, 115})));
      Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
        Placement(transformation(extent = {{90, 50}, {110, 70}})));
      Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
        Placement(transformation(extent = {{92, -70}, {112, -50}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax = inf, uMin = 0) annotation (
        Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 90, origin = {-80, 54})));
      ECUs.GMS myGMS(mapsFileName = mapsFileName) annotation (
        Placement(transformation(extent = {{-70, 10}, {-50, 30}})));
      EHPTlib.MapBased.OneFlange gen(
        wMax=maxGenW,
        mapsFileName=mapsFileName,
        mapsOnFile=true,
        powMax=maxPow,
        tauMax=maxTau,
        effTableName="gensetDriveEffTable") annotation (Placement(visible=true,
            transformation(extent={{68,18},{48,-2}}, rotation=0)));
      IceT01 mBiceT(tablesOnFile = true, mapsFileName = mapsFileName, wIceStart = wIceStart) annotation (
        Placement(transformation(extent = {{-34, -2}, {-14, 18}})));
      Modelica.Blocks.Math.Gain gain(k = -1) annotation (
        Placement(transformation(extent = {{-14, 30}, {6, 50}})));
      Modelica.Blocks.Math.Gain gain1(k = 1) annotation (
        Placement(visible = true, transformation(origin = {-60, -8}, extent = {{-6, -6}, {6, 6}}, rotation = 90)));
      Modelica.Blocks.Continuous.Integrator toGrams(k = 1 / 3600) annotation (
        Placement(transformation(extent = {{18, -42}, {38, -22}})));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = gsRatio) annotation (
        Placement(visible = true, transformation(extent = {{0, 2}, {18, 20}}, rotation = 0)));
    equation
      connect(gen.pin_p, pin_n) annotation (
        Line(points = {{68, 4.66667}, {70, 4.66667}, {70, 2.66667}, {78, 2.66667}, {78, -60}, {102, -60}}, color = {0, 0, 255}));
      connect(gain.y, gen.tauRef) annotation (
        Line(points = {{7, 40}, {75.4, 40}, {75.4, 5.5556}, {69.4, 5.5556}, {69.4, 9.11111}}, color = {0, 0, 127}));
      connect(gen.pin_n, pin_p) annotation (
        Line(points = {{68, 13.5556}, {80, 13.5556}, {80, 60}, {100, 60}}, color = {0, 0, 255}));
      connect(IcePow.flange_b, gen.flange_a) annotation (
        Line(points = {{42, 7}, {46, 7}, {46, 9.11111}, {48, 9.11111}}));
      connect(gain1.u, speedSensor.w) annotation (
        Line(points = {{-60, -15.2}, {-60, -20}, {-32.8, -20}}, color = {0, 0, 127}));
      connect(myGMS.Wmecc, gain1.y) annotation (
        Line(points = {{-59.9, 8.5}, {-60, 8.5}, {-60, -1.4}}, color = {0, 0, 127}));
      connect(limiter.u, powRef) annotation (
        Line(points = {{-80, 66}, {-80, 80}, {61, 80}, {61, 115}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(limiter.y, myGMS.pRef) annotation (
        Line(points = {{-80, 43}, {-80, 20}, {-72, 20}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(mBiceT.nTauRef, myGMS.throttle) annotation (
        Line(points = {{-30, -2}, {-30, -6}, {-49, -6}, {-49, 14}}, color = {0, 0, 127}));
      connect(speedSensor.flange, mBiceT.flange_a) annotation (
        Line(points = {{-16, -20}, {-6, -20}, {-6, 10}, {-14, 10}}, color = {0, 0, 0}));
      connect(gain.u, myGMS.tRef) annotation (
        Line(points = {{-16, 40}, {-40, 40}, {-40, 26}, {-49, 26}}, color = {0, 0, 127}));
      connect(toGrams.u, mBiceT.fuelCons) annotation (
        Line(points = {{16, -32}, {12, -32}, {8, -32}, {8, -6}, {-18, -6}, {-18, -1}}, color = {0, 0, 127}));
      connect(idealGear.flange_a, mBiceT.flange_a) annotation (
        Line(points = {{0, 11}, {-4, 11}, {-4, 10}, {-14, 10}}, color = {0, 0, 0}));
      connect(idealGear.flange_b, IcePow.flange_a) annotation (
        Line(points = {{18, 11}, {22, 11}, {22, 7}, {24, 7}}, color = {0, 0, 0}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 100}})),
        experiment(StopTime = 20, Interval = 0.01),
        experimentSetupOutput,
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-98, 94}, {78, 68}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-20, 0}, {26, -14}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-44, 30}, {-14, -44}}), Line(points = {{-72, 30}, {-72, 6}}), Polygon(points = {{-72, -2}, {-78, 8}, {-66, 8}, {-72, -2}}), Rectangle(extent = {{-96, 38}, {-50, -48}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-96, -6}, {-50, -24}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-78, -24}, {-68, -44}}), Polygon(points = {{-72, 34}, {-78, 24}, {-66, 24}, {-72, 34}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{6, 30}, {62, -44}}), Line(points = {{94, 60}, {74, 60}, {74, 18}, {62, 18}}, color = {0, 0, 255}), Line(points = {{100, -60}, {74, -60}, {74, -28}, {62, -28}}, color = {0, 0, 255})}),
        Documentation(info = "<html><head></head><body><p>Generator set containing Internal Combustion Engine (ICE), Electric generator (with DC output), and the related control.</p>
<p>The control logic tends to deliver at the DC port the input power, using the optimal generator speed.</p><p><i>Note on parameters.</i></p><p>The internal ICE data are supplied through maps to be provided through a txt file. The values explicitly set through the <i>Parameters </i>dialog box refer to the internal generator (except wIceStart). Any change on these should be made considering joint changes in the ICE maps.</p>
</body></html>"));
    end Genset;

    model GensetOO "GenSet GMS+GEN+SEngine with On/Off"
      import Modelica.Constants.inf;
      import Modelica.Constants.pi;
      parameter Real gsRatio = 2 "IdealGear speed reduction factor";
      parameter String mapsFileName = "maps.txt" "Name of the file containing data maps (names: maxIceTau, specificCons, optiSpeed)";
      parameter Modelica.SIunits.AngularVelocity maxGenW = 1e6;
      parameter Modelica.SIunits.Torque maxTau = 200 "Max mechanical torque";
      parameter Modelica.SIunits.Power maxPow = 20e3 "Max mechanical power";
      parameter Modelica.SIunits.AngularVelocity wIceStart = 300;
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(visible = true, transformation(origin = {-26, -40}, extent = {{-8, -8}, {8, 8}}, rotation = 180)));
      Modelica.Mechanics.Rotational.Components.IdealGear idealGear(ratio = gsRatio) annotation (
        Placement(visible = true, transformation(extent = {{0, -18}, {18, 0}}, rotation = 0)));
      Modelica.Blocks.Interfaces.BooleanInput ON "when true engine is ON" annotation (
        Placement(visible = true, transformation(origin = {-55, 69}, extent = {{15, -15}, {-15, 15}}, rotation = 90), iconTransformation(origin = {-60, 116}, extent = {{15, -15}, {-15, 15}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor IcePow annotation (
        Placement(visible = true, transformation(extent = {{22, -18}, {40, 0}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealInput powRef(unit = "W") "Reference genset power" annotation (
        Placement(visible = true, transformation(origin = {59, 71}, extent = {{15, -15}, {-15, 15}}, rotation = 90), iconTransformation(extent = {{15, -15}, {-15, 15}}, rotation = 90, origin = {60, 116})));
      Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
        Placement(visible = true, transformation(extent = {{88, 30}, {108, 50}}, rotation = 0), iconTransformation(extent = {{90, 50}, {110, 70}}, rotation = 0)));
      Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
        Placement(visible = true, transformation(extent = {{88, -50}, {108, -30}}, rotation = 0), iconTransformation(extent = {{92, -70}, {112, -50}}, rotation = 0)));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax = inf, uMin = 0) annotation (
        Placement(visible = true, transformation(origin = {-82, 36}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
      ECUs.GMSoo gms(mapsFileName = mapsFileName, throttlePerWerr = 0.1, tablesOnFile = true) annotation (
        Placement(visible = true, transformation(extent = {{-72, -10}, {-52, 10}}, rotation = 0)));
      OneFlange gen(wMax = maxGenW, mapsFileName = mapsFileName, mapsOnFile = true, powMax = maxPow, tauMax = maxTau, effTableName = "gensetDriveEffTable") annotation (
        Placement(visible = true, transformation(extent = {{68, 2}, {48, -18}}, rotation = 0)));
      IceT01 mbIce(wIceStart = wIceStart, mapsFileName = mapsFileName, iceJ = 10, tablesOnFile = true) annotation (
        Placement(visible = true, transformation(extent = {{-36, -22}, {-16, -2}}, rotation = 0)));
      Modelica.Blocks.Math.Gain revGain(k = -0.9 * gsRatio) annotation (
        Placement(visible = true, transformation(extent = {{-10, 10}, {10, 30}}, rotation = 0)));
      Modelica.Blocks.Continuous.Integrator toGrams(k = 1 / 3600) annotation (
        Placement(transformation(extent = {{18, -48}, {38, -28}})));
    equation
      connect(revGain.y, gen.tauRef) annotation (
        Line(points = {{11, 20}, {69.4, 20}, {69.4, -6.88889}}, color = {0, 0, 127}));
      connect(gen.pin_p, pin_n) annotation (
        Line(points = {{68, -11.3333}, {76, -11.3333}, {76, -40}, {98, -40}}, color = {0, 0, 255}));
      connect(gen.pin_n, pin_p) annotation (
        Line(points = {{68, -2.44444}, {78, -2.44444}, {78, 40}, {98, 40}}, color = {0, 0, 255}));
      connect(IcePow.flange_b, gen.flange_a) annotation (
        Line(points = {{40, -9}, {44, -9}, {44, -8.88889}, {45.875, -8.88889}, {45.875, -6.88889}, {48, -6.88889}}));
      connect(IcePow.flange_a, idealGear.flange_b) annotation (
        Line(points = {{22, -9}, {18, -9}}));
      connect(revGain.u, gms.tRef) annotation (
        Line(points = {{-12, 20}, {-38, 20}, {-38, 6}, {-51, 6}}, color = {0, 0, 127}));
      connect(mbIce.flange_a, idealGear.flange_a) annotation (
        Line(points = {{-16, -10}, {-12, -10}, {-6, -10}, {-6, -9}, {0, -9}}));
      connect(mbIce.nTauRef, gms.throttle) annotation (
        Line(points = {{-32, -22}, {-32, -26}, {-51, -26}, {-51, -6}}, color = {0, 0, 127}));
      connect(ON, gms.on) annotation (
        Line(points = {{-55, 69}, {-55, 18}, {-73.8, 18}, {-73.8, 6}}, color = {255, 0, 255}));
      connect(limiter.y, gms.pRef) annotation (
        Line(points = {{-82, 25}, {-82, 0}, {-74, 0}}, color = {0, 0, 127}));
      connect(speedSensor.w, gms.Wmecc) annotation (
        Line(points = {{-34.8, -40}, {-61.9, -40}, {-61.9, -11.5}}, color = {0, 0, 127}));
      connect(limiter.u, powRef) annotation (
        Line(points = {{-82, 48}, {-82, 52}, {59, 52}, {59, 71}}, color = {0, 0, 127}));
      connect(speedSensor.flange, idealGear.flange_a) annotation (
        Line(points = {{-18, -40}, {-6, -40}, {-6, -9}, {0, -9}}));
      connect(toGrams.u, mbIce.fuelCons) annotation (
        Line(points = {{16, -38}, {2, -38}, {2, -30}, {-20, -30}, {-20, -21}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 60}})),
        experiment(StopTime = 20, Interval = 0.01),
        experimentSetupOutput,
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-98, 94}, {78, 68}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-20, 0}, {26, -14}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-44, 30}, {-14, -44}}), Line(points = {{-72, 30}, {-72, 6}}), Polygon(points = {{-72, -2}, {-78, 8}, {-66, 8}, {-72, -2}}), Rectangle(extent = {{-96, 38}, {-50, -48}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-96, -6}, {-50, -24}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-78, -24}, {-68, -44}}), Polygon(points = {{-72, 34}, {-78, 24}, {-66, 24}, {-72, 34}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{6, 30}, {62, -44}}), Line(points = {{94, 60}, {74, 60}, {74, 18}, {62, 18}}, color = {0, 0, 255}), Line(points = {{100, -60}, {74, -60}, {74, -28}, {62, -28}}, color = {0, 0, 255})}),
        Documentation(info = "<html>
<p>Generator set containing Internal Combustion Engine, Electric generator (with DC output), and the related control.</p>
<p>The control logic tends to deliver at the DC port the input power, using the optimal generator speed.</p>
<p>In addition, it switches ON or OFF depending on the input boolean control signal.</p>
</html>"),
        __OpenModelica_commandLineOptions = "");
    end GensetOO;

    model IceConnPOO "Simple map-based ice model with connector; follows power request with ON-OFF"
      extends Partial.PartialIceP(toGramsPerkWh(fileName = mapsFileName));
      import Modelica.Constants.*;
      // rad/s
      parameter String mapsFileName = "maps.txt" "Name of the file containing data maps (names: maxIceTau, specificCons, optiSpeed)";
      SupportModels.ConnectorRelated.Conn conn annotation (
        Placement(visible = true, transformation(extent = {{-20, -78}, {20, -118}}, rotation = 0), iconTransformation(extent = {{-20, -78}, {20, -118}}, rotation = 0)));
      Modelica.Blocks.Continuous.Integrator tokgFuel(k = 1 / 3.6e6) annotation (
        Placement(visible = true, transformation(origin = {38, -76}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      Modelica.Blocks.Logical.Switch switch1 annotation (
        Placement(visible = true, transformation(origin = {2, -46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      Modelica.Blocks.Sources.Constant zero(k = 0) annotation (
        Placement(visible = true, transformation(extent = {{-46, -74}, {-26, -54}}, rotation = 0)));
      Modelica.Blocks.Math.Product toG_perHour annotation (
        Placement(visible = true, transformation(origin = {38, -42}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    equation
      connect(toG_perHour.u1, toGramsPerkWh.y) annotation (
        Line(points = {{44, -30}, {42, -30}, {42, -13}, {42, -13}}, color = {0, 0, 127}));
      connect(switch1.y, toG_perHour.u2) annotation (
        Line(points = {{13, -46}, {20, -46}, {20, -22}, {32, -22}, {32, -30}, {32, -30}}, color = {0, 0, 127}));
      connect(toG_perHour.y, tokgFuel.u) annotation (
        Line(points = {{38, -53}, {38, -53}, {38, -64}, {38, -64}}, color = {0, 0, 127}));
      connect(tokW.y, switch1.u1) annotation (
        Line(points = {{-18, -29}, {-18, -29}, {-18, -38}, {-10, -38}, {-10, -38}}, color = {0, 0, 127}));
      connect(switch1.u3, zero.y) annotation (
        Line(points = {{-10, -54}, {-18.5, -54}, {-18.5, -64}, {-25, -64}}, color = {0, 0, 127}));
      connect(switch1.u2, conn.iceON) annotation (
        Line(points = {{-10, -46}, {-60, -46}, {-60, -82}, {0, -82}, {0, -98}}, color = {255, 0, 255}));
      connect(feedback.u1, conn.icePowRef) annotation (
        Line(points = {{-88, 52}, {-88, 52}, {-88, -98}, {0, -98}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(Pice.power, conn.icePowDel) annotation (
        Line(points = {{68, 63}, {68, 63}, {68, 6}, {78, 6}, {78, -98}, {0, -98}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(w.w, conn.iceW) annotation (
        Line(points = {{58, 25}, {58, 25}, {58, 6}, {58, -98}, {0, -98}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 80}})),
        experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Simple map-based ICE model for power-split power trains - with connector</span></b> </p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This is an evolution of IceConnP: ON/OFF control is added though an hysteresis block. </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">For its general operation see the description of IceConnP.</span></p>
</html>"),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(origin = {34, -1}, lineColor = {255, 255, 255}, extent = {{32, -19}, {-48, 29}}, textString = "OO")}));
    end IceConnPOO;

    model OneFlangeConn "Simple map-based one-flange electric drive"
      extends Partial.PartialOneFlange;
      SupportModels.ConnectorRelated.Conn conn annotation (
        Placement(visible = true, transformation(extent = {{-18, -62}, {22, -102}}, rotation = 0), iconTransformation(extent = {{80, -58}, {120, -98}}, rotation = 0)));
      Modelica.Blocks.Sources.RealExpression mechPow(y = powSensor.power) annotation (
        Placement(transformation(extent = {{38, -56}, {18, -36}})));
    equation
      connect(wSensor.w, conn.genW) annotation (
        Line(points = {{78, 35.2}, {78, -72}, {2, -72}, {2, -82}}, color = {0, 0, 127}, smooth = Smooth.None),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(mechPow.y, conn.genPowDel) annotation (
        Line(points = {{17, -46}, {2, -46}, {2, -82}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{-6, 3}, {-6, 3}}, horizontalAlignment = TextAlignment.Right));
      connect(variableLimiter.u, conn.genTauRef) annotation (
        Line(points = {{-2, 30}, {6, 30}, {6, -32}, {2, -32}, {2, -82}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}, horizontalAlignment = TextAlignment.Left));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 80}})),
        Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
        Documentation(info = "<html>
<p>The input signal is interpreted as a <u>normalised</u> torque request (0 means null torque, 1 maximum availabile torque).</p>
<p>The maximum available torque is internally computed considering a direct torque maximum (tauMax) and a power maximum (powMax) </p>
<p>The requested torque is applied to a mechancal inertia. The inertia is interfaced by means ot two flanges with the exterior.</p>
<p>The model then computes the inner losses and absorbs the total power from the DC input.</p>
<p><br><u>Signals connected to the bus connecto</u>r (the names are chosen from the examples FullVehicles.PSecu1 and PSecu2 where the one-flange machine is called &QUOT;gen&QUOT;):</p>
<p>- genTauRef (input) is the torque request (Nm)</p>
<p>- genPowDel (output) is the delivered mechanical power (W)</p>
<p>- genTauLim (output) maximum available torque at the given machine rotational speed (Nm)</p>
</html>"));
    end OneFlangeConn;

    model IceConnP "Simple map-based ice model with connector; follows power request"
      extends Partial.PartialMBiceP;
      import Modelica.Constants.*;
      parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
      SupportModels.ConnectorRelated.Conn conn annotation (
        Placement(visible = true, transformation(extent = {{-20, -82}, {20, -122}}, rotation = 0), iconTransformation(extent = {{-20, -82}, {20, -122}}, rotation = 0)));
      Modelica.Blocks.Continuous.Integrator toKgFuel(k = 1 / 3.6e6) annotation (
        Placement(visible = true, transformation(origin = {24, -80}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    equation
      connect(toKgFuel.u, toG_perHour.y) annotation (
        Line(points = {{24, -68}, {24, -61}}, color = {0, 0, 127}));
      connect(feedback.u1, conn.icePowRef) annotation (
        Line(points = {{-88, 52}, {-88, 52}, {-88, -102}, {0, -102}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(Pice.power, conn.icePowDel) annotation (
        Line(points = {{68, 63}, {68, 63}, {68, 6}, {78, 6}, {78, -102}, {0, -102}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      connect(w.w, conn.iceW) annotation (
        Line(points = {{56, 25}, {58, 25}, {58, 6}, {58, -102}, {0, -102}}, color = {0, 0, 127}),
        Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 80}}, initialScale = 0.1)),
        experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
        __Dymola_experimentSetupOutput,
        Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Simple map-based ICE model for power-split power trains - with connector</span></b> </p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This is a &QUOT;connector&QUOT; version of MBiceP.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">For a general descritiption see the info of MBiceP.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Signals connected to the connector:</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowRef (input) is the power request (W). Negative values are internally converted to zero</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- iceW (output) is the measured ICE speed (rad/s)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowDel (output) delivered power (W)</span></p>
</html>"),
        Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})));
    end IceConnP;

    model GensetImGm "GenSet GMS+GEN+SEngine"
      import Modelica.Constants.inf;
      import Modelica.Constants.pi;
      parameter Modelica.SIunits.Time OptiTime "Time parameter of the PI OptiSpeed controller";
      parameter String mapsFileName = "maps.txt" "Name of the file containing data maps (names: maxIceTau, specificCons, optiSpeed)";
      parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
      parameter Modelica.SIunits.AngularVelocity wGenMax;
      parameter Modelica.SIunits.Torque maxTau = 200 "Max mechanical torque";
      parameter Modelica.SIunits.Power maxPow = 20e3 "Max mechanical power";
      Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
        Placement(transformation(extent = {{-8, -8}, {8, 8}}, rotation = 180, origin = {-24, -20})));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor IcePow annotation (
        Placement(transformation(extent = {{24, -2}, {42, 16}})));
      Modelica.Blocks.Interfaces.RealInput powRef(unit = "W") "Reference genset power" annotation (
        Placement(transformation(extent = {{15, -15}, {-15, 15}}, rotation = 90, origin = {61, 115})));
      Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
        Placement(transformation(extent = {{90, 50}, {110, 70}})));
      Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
        Placement(transformation(extent = {{92, -70}, {112, -50}})));
      Modelica.Blocks.Nonlinear.Limiter limiter(uMax = inf, uMin = 0) annotation (
        Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 90, origin = {-80, 54})));
      SHEV.PowerTrain.Gensets.GMS0 myGMS(mapsFileName = mapsFileName) annotation (
        Placement(transformation(extent = {{-70, 10}, {-50, 30}})));
      EHPowerTrain.MapBased.MBOneFlange gen(wMax = wGenMax, mapsFileName = mapsFileName, mapsOnFile = true, powMax = maxPow, tauMax = maxTau, effTableName = "gensetDriveEffTable") annotation (
        Placement(transformation(extent = {{68, 16}, {48, -4}})));
      EHPowerTrain.MapBased.MBiceT01 mBiceT(mapsFileName = mapsFileName, wIceStart = wIceStart, mapsOnFile = true, maxTauName = "maxIceTau", specConsName = "specificCons") annotation (
        Placement(transformation(extent = {{-34, -2}, {-14, 18}})));
      Modelica.Blocks.Math.Gain gain(k = -1) annotation (
        Placement(transformation(extent = {{-14, 30}, {6, 50}})));
      Modelica.Blocks.Math.Gain gain1(k = 1) annotation (
        Placement(visible = true, transformation(origin = {-60, -8}, extent = {{-6, -6}, {6, 6}}, rotation = 90)));
      Modelica.Blocks.Continuous.Integrator toGrams(k = 1 / 3600) annotation (
        Placement(transformation(extent = {{18, -42}, {38, -22}})));
    equation
      connect(gain1.u, speedSensor.w) annotation (
        Line(points = {{-60, -15.2}, {-60, -20}, {-32.8, -20}}, color = {0, 0, 127}));
      connect(myGMS.Wmecc, gain1.y) annotation (
        Line(points = {{-59.9, 8.5}, {-60, 8.5}, {-60, -1.4}}, color = {0, 0, 127}));
      connect(limiter.u, powRef) annotation (
        Line(points = {{-80, 66}, {-80, 80}, {61, 80}, {61, 115}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(limiter.y, myGMS.pRef) annotation (
        Line(points = {{-80, 43}, {-80, 20}, {-72, 20}}, color = {0, 0, 127}, smooth = Smooth.None));
      connect(IcePow.flange_b, gen.flange_a) annotation (
        Line(points = {{42, 7}, {46, 7}, {46, 6}, {48, 6}}, color = {0, 0, 0}));
      connect(gen.pin_n, pin_p) annotation (
        Line(points = {{68, 10}, {80, 10}, {80, 60}, {100, 60}}, color = {0, 0, 255}));
      connect(gen.pin_p, pin_n) annotation (
        Line(points = {{68, 2}, {78, 2}, {78, -60}, {102, -60}}, color = {0, 0, 255}));
      connect(mBiceT.nTauRef, myGMS.throttle) annotation (
        Line(points = {{-30, -2}, {-30, -6}, {-49, -6}, {-49, 14}}, color = {0, 0, 127}));
      connect(IcePow.flange_a, mBiceT.flange_a) annotation (
        Line(points = {{24, 7}, {6, 7}, {6, 10}, {-14, 10}}, color = {0, 0, 0}));
      connect(speedSensor.flange, mBiceT.flange_a) annotation (
        Line(points = {{-16, -20}, {-6, -20}, {-6, 10}, {-14, 10}}, color = {0, 0, 0}));
      connect(gain.u, myGMS.tRef) annotation (
        Line(points = {{-16, 40}, {-40, 40}, {-40, 26}, {-49, 26}}, color = {0, 0, 127}));
      connect(gain.y, gen.tauRef) annotation (
        Line(points = {{7, 40}, {49, 40}, {49, 14.6}}, color = {0, 0, 127}));
      connect(toGrams.u, mBiceT.fuelCons) annotation (
        Line(points = {{16, -32}, {12, -32}, {8, -32}, {8, -6}, {-18, -6}, {-18, -1}}, color = {0, 0, 127}));
      annotation (
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 100}})),
        experiment(StopTime = 20, Interval = 0.01),
        experimentSetupOutput,
        Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-98, 94}, {78, 68}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-20, 0}, {26, -14}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-44, 30}, {-14, -44}}), Line(points = {{-72, 30}, {-72, 6}}), Polygon(points = {{-72, -2}, {-78, 8}, {-66, 8}, {-72, -2}}), Rectangle(extent = {{-96, 38}, {-50, -48}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-96, -6}, {-50, -24}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-78, -24}, {-68, -44}}), Polygon(points = {{-72, 34}, {-78, 24}, {-66, 24}, {-72, 34}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{6, 30}, {62, -44}}), Line(points = {{94, 60}, {74, 60}, {74, 18}, {62, 18}}, color = {0, 0, 255}), Line(points = {{100, -60}, {74, -60}, {74, -28}, {62, -28}}, color = {0, 0, 255})}),
        Documentation(info = "<html>
<p>Convertitore primario con ICE e generatore</p>

</html>"));
    end GensetImGm;

    package Partial
      partial model PartialTwoFlange "Simple map-based two-flange electric drive model"
        parameter Modelica.SIunits.Power powMax = 50000 "Maximum Mechanical drive power";
        parameter Modelica.SIunits.Torque tauMax = 400 "Maximum drive Torque";
        parameter Modelica.SIunits.AngularVelocity wMax = 650 "Maximum drive speed";
        parameter Modelica.SIunits.MomentOfInertia J = 0.59 "Moment of Inertia";
        parameter Boolean mapsOnFile = false "= true, if tables are taken from a txt file";
        parameter String mapsFileName = "noName" "File where matrix is stored" annotation (
          Dialog(enable = mapsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String effTableName = "noName" "Name of the on-file maximum torque as a function of speed" annotation (
          Dialog(enable = mapsOnFile));
        parameter Real effTable[:, :] = [0, 0, 1; 0, 1, 1; 1, 1, 1] annotation (
          Dialog(enable = not mapsOnFile));
        SupportModels.MapBasedRelated.LimTau limTau(tauMax = tauMax, wMax = wMax, powMax = powMax) annotation (
          Placement(transformation(extent = {{-58, -8}, {-36, 14}})));
        SupportModels.MapBasedRelated.InertiaTq inertia(w(displayUnit = "rad/s", start = 0), J = J) annotation (
          Placement(transformation(extent = {{8, 40}, {28, 60}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedRing annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 270, origin = {-80, 40})));
        SupportModels.MapBasedRelated.EfficiencyT effMap(tauMax = tauMax, wMax = wMax, powMax = powMax, mapsOnFile = mapsOnFile, mapsFileName = mapsFileName, effTableName = effTableName, effTable = effTable) annotation (
          Placement(transformation(extent = {{20, -46}, {40, -26}})));
        SupportModels.MapBasedRelated.ConstPg constPDC annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = -90, origin = {0, 100})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor outBPow_ annotation (
          Placement(transformation(extent = {{62, 40}, {82, 60}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor outAPow_ annotation (
          Placement(transformation(extent = {{-18, 40}, {-38, 60}})));
        Modelica.Blocks.Math.Add add annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {32, 10})));
        Modelica.Mechanics.Rotational.Interfaces.Flange_b flange_b "Right flange of shaft" annotation (
          Placement(visible = true, transformation(extent = {{90, 40}, {110, 60}}, rotation = 0), iconTransformation(extent = {{90, -12}, {110, 8}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a "Left flange of shaft" annotation (
          Placement(visible = true, transformation(extent = {{-110, 40}, {-90, 60}}, rotation = 0), iconTransformation(extent = {{-110, -10}, {-90, 10}}, rotation = 0)));
        Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
          Placement(visible = true, transformation(extent = {{-70, 90}, {-50, 110}}, rotation = 0), iconTransformation(extent = {{-50, 88}, {-30, 108}}, rotation = 0)));
        Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
          Placement(visible = true, transformation(extent = {{30, 90}, {50, 110}}, rotation = 0), iconTransformation(extent = {{30, 90}, {50, 110}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.VariableLimiter torqueLimiter annotation (
          Placement(transformation(extent = {{-16, -8}, {4, 12}})));
      equation
        connect(flange_a, speedRing.flange) annotation (
          Line(points = {{-100, 50}, {-80, 50}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(effMap.w, speedRing.w) annotation (
          Line(points = {{18, -40}, {-80, -40}, {-80, 29}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(pin_p, constPDC.pin_p) annotation (
          Line(points = {{-60, 100}, {-10, 100}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(pin_n, constPDC.pin_n) annotation (
          Line(points = {{40, 100}, {9.8, 100}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(effMap.elePow, constPDC.Pref) annotation (
          Line(points = {{40.6, -36}, {52, -36}, {52, 80}, {0, 80}, {0, 91.8}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(flange_b, outBPow_.flange_b) annotation (
          Line(points = {{100, 50}, {82, 50}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_b, outBPow_.flange_a) annotation (
          Line(points = {{28, 50}, {62, 50}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_a, outAPow_.flange_a) annotation (
          Line(points = {{8, 50}, {-18, 50}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(outAPow_.flange_b, speedRing.flange) annotation (
          Line(points = {{-38, 50}, {-80, 50}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(add.u1, outBPow_.power) annotation (
          Line(points = {{38, 22}, {38, 28}, {64, 28}, {64, 39}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(add.u2, outAPow_.power) annotation (
          Line(points = {{26, 22}, {26, 28}, {-20, 28}, {-20, 39}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(torqueLimiter.limit1, limTau.yH) annotation (
          Line(points = {{-18, 10}, {-28, 10}, {-28, 9.6}, {-34.9, 9.6}}, color = {0, 0, 127}));
        connect(torqueLimiter.limit2, limTau.yL) annotation (
          Line(points = {{-18, -6}, {-28, -6}, {-28, -3.6}, {-34.9, -3.6}}, color = {0, 0, 127}));
        connect(torqueLimiter.y, inertia.tau) annotation (
          Line(points = {{5, 2}, {12.55, 2}, {12.55, 40}}, color = {0, 0, 127}));
        connect(effMap.tau, torqueLimiter.y) annotation (
          Line(points = {{18, -32}, {12, -32}, {12, 2}, {5, 2}}, color = {0, 0, 127}));
        connect(limTau.w, speedRing.w) annotation (
          Line(points = {{-60.2, 3}, {-80, 3}, {-80, 29}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(origin = {-25, 2}, extent = {{-75, 74}, {125, -74}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(origin = {4, -6}, lineColor = {0, 0, 255}, extent = {{-110, 84}, {100, 44}}, textString = "%name"), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-64, 38}, {64, -42}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-100, 10}, {-64, -10}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{64, 8}, {100, -12}}), Line(origin = {20, 0}, points = {{-60, 94}, {-60, 76}}, color = {0, 0, 255}), Line(origin = {-20, 0}, points = {{60, 94}, {60, 76}}, color = {0, 0, 255}), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-58, 14}, {58, -18}}), Text(origin = {-0.07637, 48.3161}, extent = {{-51.9236, -36.3161}, {48.0764, -66.3161}}, textString = "J=%J")}),
          Documentation(info = "<html>
<p>This model receives from the connector the torque request (variable MotTauInt) and trieds to deliver it.</p>
<p>Howeve,r before delivering the requested torque, the model limits it considering the maximum deliverable torque and power. In addition it computes and considers inner losses as determined by means of a map. </p>
</html>"));
      end PartialTwoFlange;

      partial model PartialIce "Simple  map-based Internal Combustion Engine model"
        import Modelica.Constants.*;
        parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
        // rad/s
        parameter Modelica.SIunits.MomentOfInertia iceJ = 0.5 "ICE moment of inertia";
        parameter Boolean tablesOnFile = false "= true, if tables are got from a file";
        parameter String mapsFileName = "NoName" "File where matrix is stored" annotation (
          Dialog(enable = tablesOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter Real maxIceTau[:, :] = [0, 80; 100, 80; 350, 95; 500, 95] "First column: speed (rad/s); first column: maximum ICE torque (Nm)" annotation (
          Dialog(enable = not tablesOnFile));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor w annotation (
          Placement(visible = true, transformation(origin = {52, 44}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a annotation (
          Placement(visible = true, transformation(extent = {{90, 10}, {110, 30}}, rotation = 0), iconTransformation(extent = {{90, 10}, {110, 30}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor icePow annotation (
          Placement(visible = true, transformation(extent = {{66, 50}, {86, 70}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sources.Torque Tice annotation (
          Placement(visible = true, transformation(extent = {{-12, 50}, {8, 70}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(w(fixed = true, start = wIceStart, displayUnit = "rpm"), J = iceJ) annotation (
          Placement(visible = true, transformation(extent = {{16, 50}, {36, 70}}, rotation = 0)));
        Modelica.Blocks.Math.Product toPowW annotation (
          Placement(visible = true, transformation(origin = {0, 12}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Product toG_perHour annotation (
          Placement(visible = true, transformation(origin = {30, -50}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        //  Modelica.Blocks.Continuous.Integrator toGrams(k = 1 / 3600000.0)
        // annotation(Placement(visible = true, transformation(origin = {26, -44},
        //extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Blocks.Tables.CombiTable1D toLimTau(table = maxIceTau) annotation (
          Placement(visible = true, transformation(origin = {-72, 66}, extent = {{10, -10}, {-10, 10}}, rotation = 180)));
        Modelica.Blocks.Sources.RealExpression rotorW(y = w.w) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-88, 36})));
        Modelica.Blocks.Math.Gain tokW(k = 1e-3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {0, -18})));
        Modelica.Blocks.Tables.CombiTable2D toSpecCons(tableOnFile = true, fileName = "PSDmaps.txt", tableName = "specificCons") annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = -90, origin = {40, 0})));
      equation
        connect(toPowW.u1, w.w) annotation (
          Line(points = {{6, 24}, {6, 33}, {52, 33}}, color = {0, 0, 127}));
        connect(w.flange, inertia.flange_b) annotation (
          Line(points = {{52, 54}, {52, 60}, {36, 60}}));
        connect(icePow.flange_a, inertia.flange_b) annotation (
          Line(points = {{66, 60}, {36, 60}}));
        connect(Tice.flange, inertia.flange_a) annotation (
          Line(points = {{8, 60}, {16, 60}}));
        connect(icePow.flange_b, flange_a) annotation (
          Line(points = {{86, 60}, {94, 60}, {94, 20}, {100, 20}}));
        connect(toLimTau.u[1], rotorW.y) annotation (
          Line(points = {{-84, 66}, {-88, 66}, {-88, 47}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toPowW.y, tokW.u) annotation (
          Line(points = {{-2.22045e-015, 1}, {-2.22045e-015, -2}, {2.22045e-015, -2}, {2.22045e-015, -6}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toSpecCons.y, toG_perHour.u1) annotation (
          Line(points = {{40, -11}, {40, -24}, {36, -24}, {36, -38}}, color = {0, 0, 127}));
        connect(toG_perHour.u2, tokW.y) annotation (
          Line(points = {{24, -38}, {24, -32}, {0, -32}, {0, -29}}, color = {0, 0, 127}));
        connect(toSpecCons.u2, w.w) annotation (
          Line(points = {{46, 12}, {46, 28}, {52, 28}, {52, 33}}, color = {0, 0, 127}));
        connect(toSpecCons.u1, Tice.tau) annotation (
          Line(points = {{34, 12}, {34, 12}, {34, 38}, {34, 42}, {-22, 42}, {-22, 60}, {-14, 60}}, color = {0, 0, 127}));
        connect(toPowW.u2, Tice.tau) annotation (
          Line(points = {{-6, 24}, {-6, 42}, {-22, 42}, {-22, 60}, {-14, 60}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<h4>Basic map-based ICE model.</h4>
<p>It receives as input the reference torque as a fracton of the maximum deliverable torque at a given speed. It can be approximately thought as a signal proportional to the vehicle&apos;s accelerator pedal position.</p>
<p>The generated torque is the minimum between this signal and the maximum deliverable torque at the actual engine speed (defined by means of a table).</p>
<p>From the generated torque and speed the fuel consumption is computed.</p>
<p>The used maxTorque (toLimTau) and specific fuel consumption (toSpecCons) maps are inspired to public data related to the Toyota Prius&apos; engine </p>
</html>"),Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-100, 80}, {100, -80}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-24, 68}, {76, -24}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{76, 30}, {100, 10}}), Text(origin = {0, 30}, lineColor = {0, 0, 255}, extent = {{-140, 100}, {140, 60}}, textString = "%name"), Rectangle(extent = {{-90, 68}, {-32, -26}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-90, 22}, {-32, 0}}), Line(points = {{-60, 56}, {-60, 32}}), Polygon(points = {{-60, 66}, {-66, 56}, {-54, 56}, {-60, 66}}), Polygon(points = {{-60, 24}, {-66, 34}, {-54, 34}, {-60, 24}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-64, 0}, {-54, -20}})}));
      end PartialIce;

      model PartialIceP "Simple map-based ice model with connector and Power request"
        import Modelica.Constants.*;
        parameter Real contrGain = 0.1 "Proportional controller gain (Nm/W)";
        parameter Real wIceStart = 167;
        parameter Real iceJ = 0.5 "ICE moment of Inertia (kg.m^2)";
        // rad/s
        Modelica.Mechanics.Rotational.Components.Inertia inertia(w(fixed = true, start = wIceStart, displayUnit = "rpm"), J = iceJ) annotation (
          Placement(visible = true, transformation(extent = {{30, 42}, {50, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sources.Torque iceTau annotation (
          Placement(visible = true, transformation(extent = {{4, 42}, {24, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor Pice annotation (
          Placement(transformation(extent = {{66, 62}, {86, 42}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor w annotation (
          Placement(visible = true, transformation(origin = {58, 36}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Blocks.Math.Product toPowW annotation (
          Placement(visible = true, transformation(origin = {-18, 10}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(transformation(extent = {{-90, 62}, {-70, 42}})));
        Modelica.Blocks.Math.Gain gain(k = contrGain) annotation (
          Placement(visible = true, transformation(extent = {{-62, 42}, {-42, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a annotation (
          Placement(transformation(extent = {{90, -10}, {110, 10}}), iconTransformation(extent = {{90, -10}, {110, 10}})));
        Modelica.Blocks.Tables.CombiTable2D toGramsPerkWh(fileName = "PSDmaps.txt", tableName = "iceSpecificCons", tableOnFile = true) annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = -90, origin = {42, -2})));
        Modelica.Blocks.Math.Gain tokW(k = 0.001) annotation (
          Placement(visible = true, transformation(origin = {-18, -18}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Nonlinear.Limiter limiter1(uMax = 1e99, uMin = 0) annotation (
          Placement(visible = true, transformation(origin = {-22, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
      equation
        connect(toPowW.y, tokW.u) annotation (
          Line(points = {{-18, -1}, {-18, -6}}, color = {0, 0, 127}));
        connect(toPowW.u2, iceTau.tau) annotation (
          Line(points = {{-24, 22}, {-24, 32}, {-6, 32}, {-6, 52}, {2, 52}}, color = {0, 0, 127}));
        connect(iceTau.tau, limiter1.y) annotation (
          Line(points = {{2, 52}, {-10, 52}, {-10, 52}, {-11, 52}}, color = {0, 0, 127}));
        connect(limiter1.u, gain.y) annotation (
          Line(points = {{-34, 52}, {-42, 52}, {-42, 52}, {-41, 52}}, color = {0, 0, 127}));
        connect(toGramsPerkWh.u1, iceTau.tau) annotation (
          Line(points = {{36, 10}, {36, 32}, {-6, 32}, {-6, 52}, {2, 52}}, color = {0, 0, 127}));
        connect(iceTau.flange, inertia.flange_a) annotation (
          Line(points = {{24, 52}, {30, 52}}));
        connect(w.flange, inertia.flange_b) annotation (
          Line(points = {{58, 46}, {58, 52}, {50, 52}}));
        connect(Pice.flange_a, inertia.flange_b) annotation (
          Line(points = {{66, 52}, {50, 52}}));
        connect(toGramsPerkWh.u2, w.w) annotation (
          Line(points = {{48, 10}, {48, 20}, {58, 20}, {58, 25}}, color = {0, 0, 127}));
        connect(toPowW.u1, w.w) annotation (
          Line(points = {{-12, 22}, {-12, 25}, {58, 25}}, color = {0, 0, 127}));
        connect(gain.u, feedback.y) annotation (
          Line(points = {{-64, 52}, {-71, 52}}, color = {0, 0, 127}));
        connect(Pice.flange_b, flange_a) annotation (
          Line(points = {{86, 52}, {94, 52}, {94, 0}, {100, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(feedback.u2, Pice.power) annotation (
          Line(points = {{-80, 60}, {-80, 72}, {68, 72}, {68, 63}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Simple map-based ICE model for power-split power trains - with connector</b> </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This is a &QUOT;connector&QUOT; version of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">For a general descritiption see the info of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Signals connected to the connector:</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowRef (input) is the power request (W). Negative values are internally converted to zero</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- iceW (output) is the measured ICE speed (rad/s)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowDel (output) delivered power (W)</span></p>
</html>"),Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-24, 48}, {76, -44}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{76, 10}, {100, -10}}), Text(origin = {-2, 0}, extent = {{-140, -52}, {140, -86}}, textString = "J=%J"), Rectangle(extent = {{-100, 62}, {100, -100}}), Text(origin = {0, 10}, lineColor = {0, 0, 255}, extent = {{-140, 100}, {140, 60}}, textString = "%name"), Rectangle(extent = {{-90, 48}, {-32, -46}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-90, 2}, {-32, -20}}), Line(points = {{-60, 36}, {-60, 12}}), Polygon(points = {{-60, 46}, {-66, 36}, {-54, 36}, {-60, 46}}), Polygon(points = {{-60, 4}, {-66, 14}, {-54, 14}, {-60, 4}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-64, -20}, {-54, -40}})}),
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-90, 20}, {-46, -16}}, textString = "follows the power
reference \nand computes consumption")}));
      end PartialIceP;

      partial model PartialOneFlange "Partial map-based one-Flange electric drive model"
        parameter Modelica.SIunits.Power powMax = 22000 "Maximum mechnical power";
        parameter Modelica.SIunits.Torque tauMax = 80 "Maximum torque";
        parameter Modelica.SIunits.Voltage uDcNom = 100 "nominal DC voltage";
        parameter Modelica.SIunits.AngularVelocity wMax(min = powMax / tauMax) = 3000 "Maximum drive speed";
        parameter Modelica.SIunits.MomentOfInertia J = 0.25 "Rotor's moment of inertia";
        parameter Boolean mapsOnFile = false "= true, if tables are taken from a txt file";
        parameter String mapsFileName = "noName" "File where matrix is stored" annotation (
          Dialog(enable = mapsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String effTableName = "noName" "Name of the on-file efficiency matrix" annotation (
          Dialog(enable = mapsOnFile));
        parameter Real effTable[:, :] = [0, 0, 1; 0, 1, 1; 1, 1, 1] "rows: speeds; columns: torques; both p.u. of max" annotation (
          Dialog(enable = not mapsOnFile));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a "Left flange of shaft" annotation (
          Placement(transformation(extent = {{88, 50}, {108, 70}}, rotation = 0), iconTransformation(extent = {{90, -10}, {110, 10}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wSensor annotation (
          Placement(transformation(extent = {{8, -8}, {-8, 8}}, rotation = 90, origin = {78, 44})));
        SupportModels.MapBasedRelated.LimTau limTau(tauMax = tauMax, wMax = wMax, powMax = powMax) annotation (
          Placement(transformation(extent = {{40, 18}, {20, 42}})));
        SupportModels.MapBasedRelated.EfficiencyT toElePow(mapsOnFile = mapsOnFile, tauMax = tauMax, powMax = powMax, wMax = wMax, mapsFileName = mapsFileName, effTableName = effTableName, effTable = effTable) annotation (
          Placement(transformation(extent = {{-6, -28}, {-26, -8}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
          Placement(transformation(extent = {{-110, 30}, {-90, 50}}), iconTransformation(extent = {{-110, 30}, {-90, 50}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
          Placement(transformation(extent = {{-110, -50}, {-90, -30}}), iconTransformation(extent = {{-110, -50}, {-90, -30}})));
        SupportModels.MapBasedRelated.ConstPg constPDC(vNom = uDcNom) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-100, 0})));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = J) annotation (
          Placement(transformation(extent = {{22, 50}, {42, 70}})));
        Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
          Placement(transformation(extent = {{-16, 50}, {4, 70}})));
        Modelica.Blocks.Math.Gain gain(k = 1) annotation (
          Placement(transformation(extent = {{-64, -10}, {-84, 10}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powSensor annotation (
          Placement(transformation(extent = {{50, 50}, {70, 70}})));
        Modelica.Blocks.Nonlinear.VariableLimiter variableLimiter annotation (
          Placement(transformation(extent = {{-4, 20}, {-24, 40}})));
      equation
        assert(wMax >= powMax / tauMax, "\n****\n" + "PARAMETER VERIFICATION ERROR:\nwMax must be not lower than powMax/tauMax" + "\n***\n");
        connect(toElePow.w, wSensor.w) annotation (
          Line(points = {{-4, -22}, {78, -22}, {78, 35.2}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(pin_p, constPDC.pin_p) annotation (
          Line(points = {{-100, 40}, {-100, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(pin_n, constPDC.pin_n) annotation (
          Line(points = {{-100, -40}, {-100, -9.8}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(constPDC.Pref, gain.y) annotation (
          Line(points = {{-91.8, 0}, {-85, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(powSensor.flange_b, flange_a) annotation (
          Line(points = {{70, 60}, {98, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(wSensor.flange, flange_a) annotation (
          Line(points = {{78, 52}, {78, 60}, {98, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(toElePow.elePow, gain.u) annotation (
          Line(points = {{-26.6, -18}, {-46, -18}, {-46, 0}, {-62, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(inertia.flange_a, torque.flange) annotation (
          Line(points = {{22, 60}, {4, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_b, powSensor.flange_a) annotation (
          Line(points = {{42, 60}, {50, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(variableLimiter.limit1, limTau.yH) annotation (
          Line(points = {{-2, 38}, {19, 38}, {19, 37.2}}, color = {0, 0, 127}));
        connect(variableLimiter.limit2, limTau.yL) annotation (
          Line(points = {{-2, 22}, {10, 22}, {10, 22.8}, {19, 22.8}}, color = {0, 0, 127}));
        connect(variableLimiter.y, torque.tau) annotation (
          Line(points = {{-25, 30}, {-36, 30}, {-36, 60}, {-18, 60}}, color = {0, 0, 127}));
        connect(toElePow.tau, torque.tau) annotation (
          Line(points = {{-4, -14}, {2, -14}, {2, 12}, {-36, 12}, {-36, 60}, {-18, 60}}, color = {0, 0, 127}));
        connect(limTau.w, wSensor.w) annotation (
          Line(points = {{42, 30}, {78, 30}, {78, 35.2}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-70, 80}, {100, -80}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{62, -7}, {82, -7}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{52, 10}, {100, -10}}), Line(points = {{-98, 40}, {-70, 40}}, color = {0, 0, 255}), Line(points = {{-92, -40}, {-70, -40}}, color = {0, 0, 255}), Text(origin = {0, 20}, lineColor = {0, 0, 255}, extent = {{-70, 98}, {100, 60}}, textString = "%name", fillPattern = FillPattern.Solid, fillColor = {255, 255, 255}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-56, 48}, {76, -48}}), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-48, 14}, {66, -14}}), Text(origin = {6.1429, 47.1}, extent = {{-54.1429, -35.1}, {61.8571, -61.1}}, textString = "J=%J")}),
          Documentation(info = "<html>
<p>One-flange electric drive.</p>
<p>The input signal is the requested normalised torque (1 means nominal torque)</p>
</html>"));
      end PartialOneFlange;

      partial model PartialMBice "Simple  map-based Internal Combustion Engine model"
        import Modelica.Constants.*;
        parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
        parameter Modelica.SIunits.MomentOfInertia iceJ = 0.5 "ICE moment of inertia";
        parameter Boolean mapsOnFile = false "= true, if tables are taken from a txt file";
        parameter String mapsFileName = "NoName" "File where matrix is stored" annotation (
          Dialog(enable = mapsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String maxTauName = "noName" "name of the on-file maximum torque as a function of speed" annotation (
          Dialog(enable = mapsOnFile));
        parameter String specConsName = "noName" "name of the on-file specific consumption variable" annotation (
          Dialog(enable = mapsOnFile));
        parameter Real maxIceTau[:, :] = [0, 80; 100, 80; 350, 95; 500, 95] "First column speed, second column maximum ice torque" annotation (
          Dialog(enable = not mapsOnFile));
        parameter Real specificConsTab[:, :](unit = "g/(kW.h)") = [0., 100, 200, 300, 400, 500; 10, 630, 580, 550, 580, 630; 20, 430, 420, 400, 400, 450; 30, 320, 325, 330, 340, 350; 40, 285, 285, 288, 290, 300; 50, 270, 265, 265, 270, 275; 60, 255, 248, 250, 255, 258; 70, 245, 237, 238, 243, 246; 80, 245, 230, 233, 237, 240; 90, 235, 230, 228, 233, 235] "ICE specific consumption map. First column torque, first row speed" annotation (
          Dialog(enable = not mapsOnFile));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor w annotation (
          Placement(visible = true, transformation(origin = {52, 44}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a annotation (
          Placement(visible = true, transformation(extent = {{90, 10}, {110, 30}}, rotation = 0), iconTransformation(extent = {{90, 10}, {110, 30}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor icePow annotation (
          Placement(visible = true, transformation(extent = {{66, 50}, {86, 70}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sources.Torque Tice annotation (
          Placement(visible = true, transformation(extent = {{-12, 50}, {8, 70}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(w(fixed = true, start = wIceStart, displayUnit = "rpm"), J = iceJ) annotation (
          Placement(visible = true, transformation(extent = {{16, 50}, {36, 70}}, rotation = 0)));
        Modelica.Blocks.Math.Product toPow0 annotation (
          Placement(visible = true, transformation(origin = {0, 12}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Product toG_perHour annotation (
          Placement(visible = true, transformation(origin = {30, -50}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        //  Modelica.Blocks.Continuous.Integrator toGrams(k = 1 / 3600000.0)
        // annotation(Placement(visible = true, transformation(origin = {26, -44},
        //extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Blocks.Tables.CombiTable1D toLimTau(tableOnFile = mapsOnFile, table = maxIceTau, tableName = maxTauName, fileName = mapsFileName) annotation (
          Placement(visible = true, transformation(origin = {-72, 66}, extent = {{10, -10}, {-10, 10}}, rotation = 180)));
        Modelica.Blocks.Sources.RealExpression rotorW(y = w.w) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-88, 36})));
        Modelica.Blocks.Math.Gain tokW(k = 1e-3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {0, -18})));
        Modelica.Blocks.Tables.CombiTable2D toSpecCons(tableOnFile = mapsOnFile, table = specificConsTab, tableName = specConsName, fileName = mapsFileName) annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = -90, origin = {40, 0})));
      equation
        connect(toPow0.u1, w.w) annotation (
          Line(points = {{6, 24}, {6, 33}, {52, 33}}, color = {0, 0, 127}));
        connect(w.flange, inertia.flange_b) annotation (
          Line(points = {{52, 54}, {52, 60}, {36, 60}}));
        connect(icePow.flange_a, inertia.flange_b) annotation (
          Line(points = {{66, 60}, {36, 60}}));
        connect(Tice.flange, inertia.flange_a) annotation (
          Line(points = {{8, 60}, {16, 60}}));
        connect(icePow.flange_b, flange_a) annotation (
          Line(points = {{86, 60}, {94, 60}, {94, 20}, {100, 20}}));
        connect(toLimTau.u[1], rotorW.y) annotation (
          Line(points = {{-84, 66}, {-88, 66}, {-88, 47}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toPow0.y, tokW.u) annotation (
          Line(points = {{-2.22045e-015, 1}, {-2.22045e-015, -2}, {2.22045e-015, -2}, {2.22045e-015, -6}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toSpecCons.y, toG_perHour.u1) annotation (
          Line(points = {{40, -11}, {40, -24}, {36, -24}, {36, -38}}, color = {0, 0, 127}));
        connect(toG_perHour.u2, tokW.y) annotation (
          Line(points = {{24, -38}, {24, -32}, {0, -32}, {0, -29}}, color = {0, 0, 127}));
        connect(toSpecCons.u2, w.w) annotation (
          Line(points = {{46, 12}, {46, 28}, {52, 28}, {52, 33}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<h4>Basic map-based ICE model.</h4>
<p>It receives as input the reference torque as a fracton of the maximum deliverable torque at a given speed. It can be approximately thought as a signal proportional to the accelerator position oF the vehicle.</p>
<p>The generated torque is the minimum between this signal and the maximum deliverable torque at the actual engine speed (defined by means of a table).</p>
<p>From the generated torque and speed the fuel consumption is computed.</p>
<p>The used maxTorque (toLimTau) and specific fuel consumption (toSpecCons) maps are inspired to public data related to the Toyota Prius&apos; engine </p>
</html>"),Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-100, 80}, {100, -80}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-24, 68}, {76, -24}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{76, 30}, {100, 10}}), Text(origin = {0, 30}, lineColor = {0, 0, 255}, extent = {{-140, 100}, {140, 60}}, textString = "%name"), Rectangle(extent = {{-90, 68}, {-32, -26}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-90, 22}, {-32, 0}}), Line(points = {{-60, 56}, {-60, 32}}), Polygon(points = {{-60, 66}, {-66, 56}, {-54, 56}, {-60, 66}}), Polygon(points = {{-60, 24}, {-66, 34}, {-54, 34}, {-60, 24}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-64, 0}, {-54, -20}})}));
      end PartialMBice;

      partial model PartialMBiceP "Simple map-based ice model with connector and Power request"
        import Modelica.Constants.*;
        parameter Real contrGain(unit = "N.m/W") = 0.1 "Proportional controller gain ";
        parameter Modelica.SIunits.AngularVelocity wIceStart = 167;
        parameter Modelica.SIunits.MomentOfInertia iceJ = 0.5 "ICE moment of Inertia";
        parameter Boolean mapsOnFile = false "= true, if tables are taken from a txt file";
        parameter String mapsFileName = "NoName" "File where matrix is stored" annotation (
          Dialog(enable = mapsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String specConsName = "noName" "name of the on-file specific consumption variable" annotation (
          Dialog(enable = mapsOnFile));
        parameter Real specificCons[:, :](each unit = "g/(kW.h)") = [0.0, 100, 200, 300, 400, 500; 10, 630, 580, 550, 580, 630; 20, 430, 420, 400, 400, 450; 30, 320, 325, 330, 340, 350; 40, 285, 285, 288, 290, 300; 50, 270, 265, 265, 270, 275; 60, 255, 248, 250, 255, 258; 70, 245, 237, 238, 243, 246; 80, 245, 230, 233, 237, 240; 90, 235, 230, 228, 233, 235] "ICE specific consumption map. First column torque, first row speed" annotation (
          Dialog(enable = not mapsOnFile));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(w(fixed = true, start = wIceStart, displayUnit = "rpm"), J = iceJ) annotation (
          Placement(visible = true, transformation(extent = {{30, 42}, {50, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sources.Torque iceTau annotation (
          Placement(visible = true, transformation(extent = {{4, 42}, {24, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor Pice annotation (
          Placement(transformation(extent = {{66, 62}, {86, 42}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor w annotation (
          Placement(visible = true, transformation(origin = {56, 36}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Blocks.Math.Product toPow0 annotation (
          Placement(visible = true, transformation(origin = {-10, 8}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(transformation(extent = {{-90, 62}, {-70, 42}})));
        Modelica.Blocks.Math.Gain gain(k = contrGain) annotation (
          Placement(visible = true, transformation(extent = {{-62, 42}, {-42, 62}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a annotation (
          Placement(transformation(extent = {{90, -10}, {110, 10}}), iconTransformation(extent = {{90, -10}, {110, 10}})));
        Modelica.Blocks.Tables.CombiTable2D toGramsPerKWh(table = specificCons, tableOnFile = mapsOnFile, tableName = specConsName, fileName = mapsFileName) annotation (
          Placement(transformation(extent = {{-10, 10}, {10, -10}}, rotation = -90, origin = {42, -2})));
        Modelica.Blocks.Math.Gain tokW(k = 1e-3) annotation (
          Placement(visible = true, transformation(origin = {-10, -22}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Nonlinear.Limiter limiter1(limitsAtInit = true, uMax = 1e99, uMin = 0) annotation (
          Placement(visible = true, transformation(origin = {-22, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Math.Product toG_perHour annotation (
          Placement(visible = true, transformation(origin = {24, -50}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
      equation
        connect(toPow0.u2, iceTau.tau) annotation (
          Line(points = {{-16, 20}, {-16, 34}, {-6, 34}, {-6, 52}, {2, 52}}, color = {0, 0, 127}));
        connect(iceTau.tau, limiter1.y) annotation (
          Line(points = {{2, 52}, {-12, 52}, {-12, 52}, {-11, 52}}, color = {0, 0, 127}));
        connect(limiter1.u, gain.y) annotation (
          Line(points = {{-34, 52}, {-42, 52}, {-42, 52}, {-41, 52}}, color = {0, 0, 127}));
        connect(toGramsPerKWh.y, toG_perHour.u1) annotation (
          Line(points = {{42, -13}, {42, -20}, {30, -20}, {30, -38}}, color = {0, 0, 127}));
        connect(tokW.y, toG_perHour.u2) annotation (
          Line(points = {{-10, -33}, {10, -33}, {10, -20}, {18, -20}, {18, -38}}, color = {0, 0, 127}));
        connect(tokW.u, toPow0.y) annotation (
          Line(points = {{-10, -10}, {-10, -3}}, color = {0, 0, 127}));
        connect(toPow0.u2, toGramsPerKWh.u1) annotation (
          Line(points = {{-16, 20}, {-16, 34}, {36, 34}, {36, 10}}, color = {0, 0, 127}));
        connect(toPow0.u1, w.w) annotation (
          Line(points = {{-4, 20}, {-4, 25}, {56, 25}}, color = {0, 0, 127}));
        connect(iceTau.flange, inertia.flange_a) annotation (
          Line(points = {{24, 52}, {30, 52}}));
        connect(toGramsPerKWh.u2, w.w) annotation (
          Line(points = {{48, 10}, {48, 20}, {56, 20}, {56, 25}}, color = {0, 0, 127}));
        connect(w.flange, inertia.flange_b) annotation (
          Line(points = {{56, 46}, {56, 52}, {50, 52}}));
        connect(Pice.flange_a, inertia.flange_b) annotation (
          Line(points = {{66, 52}, {50, 52}}));
        connect(gain.u, feedback.y) annotation (
          Line(points = {{-64, 52}, {-71, 52}}, color = {0, 0, 127}));
        connect(Pice.flange_b, flange_a) annotation (
          Line(points = {{86, 52}, {94, 52}, {94, 0}, {100, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(feedback.u2, Pice.power) annotation (
          Line(points = {{-80, 60}, {-80, 72}, {68, 72}, {68, 63}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 80}}), graphics = {Text(extent = {{-78, 6}, {-38, -16}}, textString = "follows the power
 reference and
 computes consumption")}),
          experiment(StopTime = 200, __Dymola_NumberOfIntervals = 1000, __Dymola_Algorithm = "Lsodar"),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Simple map-based ICE model for power-split power trains - with connector</b> </span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This is a &QUOT;connector&QUOT; version of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">For a general descritiption see the info of MBice.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">Signals connected to the connector:</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowRef (input) is the power request (W). Negative values are internally converted to zero</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- iceW (output) is the measured ICE speed (rad/s)</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">- icePowDel (output) delivered power (W)</span></p>
</html>"),Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-24, 48}, {76, -44}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{76, 10}, {100, -10}}), Text(origin = {-2, 0}, extent = {{-140, -52}, {140, -90}}, textString = "J=%J"), Rectangle(extent = {{-100, 62}, {100, -100}}), Text(origin = {0, 10}, lineColor = {0, 0, 255}, extent = {{-140, 100}, {140, 60}}, textString = "%name"), Rectangle(extent = {{-90, 48}, {-32, -46}}), Rectangle(fillColor = {95, 95, 95}, fillPattern = FillPattern.Solid, extent = {{-90, 2}, {-32, -20}}), Line(points = {{-60, 36}, {-60, 12}}), Polygon(points = {{-60, 46}, {-66, 36}, {-54, 36}, {-60, 46}}), Polygon(points = {{-60, 4}, {-66, 14}, {-54, 14}, {-60, 4}}), Rectangle(fillColor = {135, 135, 135}, fillPattern = FillPattern.Solid, extent = {{-64, -20}, {-54, -40}})}));
      end PartialMBiceP;

      partial model PartialOneFlange2 "Partial map-based one-Flange electric drive model"
        parameter Modelica.SIunits.Voltage uDcNom = 100 "nominal DC voltage";
        parameter Modelica.SIunits.MomentOfInertia J = 0.25 "Rotor's moment of inertia";
        parameter Boolean effMapOnFile = false "= true, if tables are taken from a txt file";
        parameter String mapsFileName = "noName" "File where efficiency/limits matrix/ces is/are stored" annotation (
          Dialog(enable = effMapOnFile or limitsOnFile, loadSelector(filter = "Text files (*.txt)", caption = "Open file in which required tables are")));
        parameter String effTableName = "noName" "Name of the on-file efficiency matrix" annotation (
          Dialog(enable = effMapOnFile));
        parameter Real effTable[:, :] = [0, 0, 1; 0, 1, 1; 1, 1, 1] "rows: speeds; columns: torques; both p.u. of max" annotation (
          Dialog(enable = not effMapOnFile));
        parameter Boolean limitsOnFile = false "= true, if torque limits are taken from a txt file";
        parameter Modelica.SIunits.Power powMax = 22000 "Maximum mechnical power" annotation (
          Dialog(enable = not limitsOnFile));
        parameter Modelica.SIunits.Torque tauMax = 80 "Maximum torque" annotation (
          Dialog(enable = not limitsOnFile));
        parameter Modelica.SIunits.AngularVelocity wMax(min = powMax / tauMax) = 3000 "Maximum drive speed" annotation (
          Dialog(enable = not limitsOnFile));
        parameter String maxTorqueTableName = "noName" "Name of the on-file upper torque limit" annotation (
          Dialog(enable = limitsOnFile));
        parameter String minTorqueTableName = "noName" "Name of the on-file lower torque limit" annotation (
          Dialog(enable = limitsOnFile));
        Modelica.Mechanics.Rotational.Interfaces.Flange_a flange_a "Left flange of shaft" annotation (
          Placement(transformation(extent = {{88, 50}, {108, 70}}, rotation = 0), iconTransformation(extent = {{90, -10}, {110, 10}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wSensor annotation (
          Placement(transformation(extent = {{8, -8}, {-8, 8}}, rotation = 90, origin = {78, 44})));
        SupportModels.MapBasedRelated.LimTorque limTau(limitsOnFile = limitsOnFile, tauMax = tauMax, wMax = wMax, powMax = powMax, limitsFileName = mapsFileName, maxTorqueTableName = maxTorqueTableName, minTorqueTableName = minTorqueTableName) annotation (
          Placement(transformation(extent = {{40, 18}, {20, 42}})));
        SupportModels.MapBasedRelated.EfficiencyT toElePow(mapsOnFile = effMapOnFile, tauMax = tauMax, powMax = powMax, wMax = wMax, mapsFileName = mapsFileName, effTableName = effTableName, effTable = effTable) annotation (
          Placement(transformation(extent = {{-6, -28}, {-26, -8}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin pin_p annotation (
          Placement(transformation(extent = {{-110, 30}, {-90, 50}}), iconTransformation(extent = {{-110, 30}, {-90, 50}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin pin_n annotation (
          Placement(transformation(extent = {{-110, -50}, {-90, -30}}), iconTransformation(extent = {{-110, -50}, {-90, -30}})));
        SupportModels.MapBasedRelated.ConstPg constPDC(vNom = uDcNom) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-100, 0})));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = J) annotation (
          Placement(transformation(extent = {{22, 50}, {42, 70}})));
        Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
          Placement(transformation(extent = {{-16, 50}, {4, 70}})));
        Modelica.Blocks.Math.Gain gain(k = 1) annotation (
          Placement(transformation(extent = {{-64, -10}, {-84, 10}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powSensor annotation (
          Placement(transformation(extent = {{50, 50}, {70, 70}})));
        Modelica.Blocks.Nonlinear.VariableLimiter variableLimiter annotation (
          Placement(transformation(extent = {{-4, 20}, {-24, 40}})));
      equation
        assert(wMax >= powMax / tauMax, "\n****\n" + "PARAMETER VERIFICATION ERROR:\nwMax must be not lower than powMax/tauMax" + "\n***\n");
        connect(toElePow.w, wSensor.w) annotation (
          Line(points = {{-4, -22}, {78, -22}, {78, 35.2}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(pin_p, constPDC.pin_p) annotation (
          Line(points = {{-100, 40}, {-100, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(pin_n, constPDC.pin_n) annotation (
          Line(points = {{-100, -40}, {-100, -9.8}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(constPDC.Pref, gain.y) annotation (
          Line(points = {{-91.8, 0}, {-85, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(powSensor.flange_b, flange_a) annotation (
          Line(points = {{70, 60}, {98, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(wSensor.flange, flange_a) annotation (
          Line(points = {{78, 52}, {78, 60}, {98, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(toElePow.elePow, gain.u) annotation (
          Line(points = {{-26.6, -18}, {-46, -18}, {-46, 0}, {-62, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(inertia.flange_a, torque.flange) annotation (
          Line(points = {{22, 60}, {4, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_b, powSensor.flange_a) annotation (
          Line(points = {{42, 60}, {50, 60}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(variableLimiter.limit1, limTau.yH) annotation (
          Line(points = {{-2, 38}, {19, 38}, {19, 37.2}}, color = {0, 0, 127}));
        connect(variableLimiter.limit2, limTau.yL) annotation (
          Line(points = {{-2, 22}, {10, 22}, {10, 22.8}, {19, 22.8}}, color = {0, 0, 127}));
        connect(variableLimiter.y, torque.tau) annotation (
          Line(points = {{-25, 30}, {-36, 30}, {-36, 60}, {-18, 60}}, color = {0, 0, 127}));
        connect(toElePow.tau, torque.tau) annotation (
          Line(points = {{-4, -14}, {2, -14}, {2, 12}, {-36, 12}, {-36, 60}, {-18, 60}}, color = {0, 0, 127}));
        connect(limTau.w, wSensor.w) annotation (
          Line(points = {{42, 30}, {78, 30}, {78, 35.2}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-70, 80}, {100, -80}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{62, -7}, {82, -7}}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{52, 10}, {100, -10}}), Line(points = {{-98, 40}, {-70, 40}}, color = {0, 0, 255}), Line(points = {{-92, -40}, {-70, -40}}, color = {0, 0, 255}), Text(origin = {0, 20}, lineColor = {0, 0, 255}, extent = {{-70, 98}, {100, 60}}, textString = "%name", fillPattern = FillPattern.Solid, fillColor = {255, 255, 255}), Rectangle(fillColor = {192, 192, 192}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-56, 48}, {76, -48}}), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-48, 14}, {66, -14}}), Text(origin = {6.1429, 47.1}, extent = {{-54.1429, -35.1}, {61.8571, -61.1}}, textString = "J=%J")}),
          Documentation(info = "<html>
<p>One-flange electric drive.</p>
<p>The input signal is the requested normalised torque (1 means nominal torque)</p>
</html>"));
      end PartialOneFlange2;
    end Partial;

    package TestingModels
      extends Modelica.Icons.ExamplesPackage;

      model TestIceT
        IceT iceT(wIceStart = 90) annotation (
          Placement(transformation(extent = {{-20, -2}, {0, 18}})));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5, phi(start = 0, fixed = true)) annotation (
          Placement(transformation(extent = {{10, 0}, {30, 20}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque loadTorque(w_nominal = 100, tau_nominal = -80) annotation (
          Placement(transformation(extent = {{64, 0}, {44, 20}})));
        Modelica.Blocks.Sources.Trapezoid trapezoid(rising = 10, width = 10, falling = 10, period = 1e6, startTime = 10, offset = 60, amplitude = 30) annotation (
          Placement(transformation(extent = {{-50, -38}, {-30, -18}})));
      equation
        connect(iceT.flange_a, inertia.flange_a) annotation (
          Line(points = {{0, 10}, {10, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_b, loadTorque.flange) annotation (
          Line(points = {{30, 10}, {44, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(iceT.tauRef, trapezoid.y) annotation (
          Line(points = {{-16, -2}, {-16, -28}, {-29, -28}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-60, -60}, {80, 40}}), graphics),
          experiment(StopTime = 50),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-60, -60}, {80, 40}})),
          Documentation(info = "<html>
<p>This is a simple test of model IceT.</p>
<p>It shows that the generated torque follows the torque request as long as the maximum allowed is not overcome; otherwise this maximum is generated.</p>
<p>It shows also the fuel consumption output.</p>
<p>The user could compare the torque request tauRef with the torque generated and at the ICE flange (with this transient the inertia torques are very small and can be neglected). The user could also have a look at the rotational speeds and fuel consumption. </p>
</html>"));
      end TestIceT;

      model TestOneFlange
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5, phi(start = 0, fixed = true), w(start = 50, fixed = true)) annotation (
          Placement(transformation(extent = {{38, 0}, {58, 20}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque loadTorque(tau_nominal = -50, w_nominal = 400) annotation (
          Placement(transformation(extent = {{92, 0}, {72, 20}})));
        Modelica.Blocks.Sources.Trapezoid tauRef(rising = 10, width = 10, falling = 10, period = 1e6, startTime = 10, amplitude = 50, offset = 20) annotation (
          Placement(transformation(extent = {{-60, -38}, {-40, -18}})));
        OneFlange oneFlange(powMax = 10000, tauMax = 50, J = 0.5, wMax = 300) annotation (
          Placement(transformation(extent = {{-22, 0}, {-2, 20}})));
        Modelica.Electrical.Analog.Sources.ConstantVoltage gen(V = 100) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {-64, 10})));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(transformation(extent = {{-90, -20}, {-70, 0}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powMech annotation (
          Placement(transformation(extent = {{12, 0}, {32, 20}})));
        Modelica.Electrical.Analog.Sensors.PowerSensor powElec annotation (
          Placement(transformation(extent = {{-48, 20}, {-28, 40}})));
      equation
        connect(inertia.flange_b, loadTorque.flange) annotation (
          Line(points = {{58, 10}, {72, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(tauRef.y, oneFlange.tauRef) annotation (
          Line(points = {{-39, -28}, {-32, -28}, {-32, 8}, {-23.4, 8}, {-23.4, 8.88889}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(ground.p, gen.n) annotation (
          Line(points = {{-80, 0}, {-64, 0}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(oneFlange.flange_a, powMech.flange_a) annotation (
          Line(points = {{-2, 8.88889}, {6, 8.88889}, {6, 10}, {12, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(inertia.flange_a, powMech.flange_b) annotation (
          Line(points = {{38, 10}, {32, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(powElec.nc, oneFlange.pin_p) annotation (
          Line(points = {{-28, 30}, {-8, 30}, {-8, 20}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.pc, gen.p) annotation (
          Line(points = {{-48, 30}, {-64, 30}, {-64, 20}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.pv, powElec.nc) annotation (
          Line(points = {{-38, 40}, {-28, 40}, {-28, 30}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(gen.n, oneFlange.pin_n) annotation (
          Line(points = {{-64, 0}, {-38, 0}, {-38, 20}, {-17.8, 20}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.nv, oneFlange.pin_n) annotation (
          Line(points = {{-38, 20}, {-17.8, 20}}, color = {0, 0, 255}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 60}}), graphics),
          experiment(StopTime = 50),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})),
          Documentation(info = "<html>
<p>This is a simple test of model OneFlange.</p>
<p>It shows that the generated torque follows the normalised torque request as long as it does not overcome unity. Actual torque will be this request times the maximum value that, in turn, is the minimum between tauMax and powerMax/w (while w is the rotational speed)</p>
<p>It shows also the effects of efficiency on the DC power.</p>
<p><u>First suggested plots</u>: on the same axis oneFlange.torque.tau, and tauRef vertically aligned with the previous oneFlange.limTau.state. In these plots it can be seen that:</p>
<ul>
<li>during the first 10 seconds the generated torque oneFlange.torque.tau, is 20Nm, as requested from the input. The maximum torque that can be generated is not limited by the power limit</li>
<li>between t=10 and 12 s the generated torque continues to follow the input signal; </li>
<li>between t=12 and 37.7 s, since the drive power has been reached (10 kW), the generated torque is automatically reduced to avoid this limit to be overcome </li>
<li>above t=37.7 the torque request is reduced and the drive is again able to deliver this torque.</li>
<li>All the above behaviour is confirmed by the value of boolean variable tauLimited.y.</li>
</ul>
<p><br><u>Second suggested plot</u>: Once the first plot is anaysed, the user might want to have an idea of the mechanical and electrical powers: these are seen putting in the same plot powMech.power and powElec.power.</p>
</html>"));
      end TestOneFlange;

      model TestIceConn
        Modelica.Mechanics.Rotational.Components.Inertia inertia(phi(start = 0, fixed = true), J = 10) annotation (
          Placement(transformation(extent = {{-14, 0}, {6, 20}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque loadTorque(w_nominal = 100, tau_nominal = -80) annotation (
          Placement(transformation(extent = {{64, 0}, {44, 20}})));
        IceConnP ice(wIceStart = 90, mapsFileName = "PSDmaps.txt") annotation (
          Placement(transformation(extent = {{-42, 0}, {-22, 20}})));
        SupportModels.ConnectorRelated.ToConnIcePowRef toConnIceTauRef annotation (
          Placement(transformation(extent = {{-6, -6}, {6, 6}}, rotation = 90, origin = {-32, -18})));
        Modelica.Blocks.Sources.Trapezoid powReq(rising = 10, width = 10, falling = 10, period = 1e6, startTime = 10, offset = 60, amplitude = 10e3) annotation (
          Placement(transformation(extent = {{-74, -30}, {-54, -10}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor outPow annotation (
          Placement(transformation(extent = {{18, 0}, {38, 20}})));
      equation
        connect(inertia.flange_a, ice.flange_a) annotation (
          Line(points = {{-14, 10}, {-22, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(toConnIceTauRef.conn, ice.conn) annotation (
          Line(points = {{-32, -12}, {-32, 0.2}}, color = {255, 204, 51}, thickness = 0.5, smooth = Smooth.None));
        connect(toConnIceTauRef.u, powReq.y) annotation (
          Line(points = {{-32, -25.4}, {-32, -32}, {-44, -32}, {-44, -20}, {-53, -20}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(inertia.flange_b, outPow.flange_a) annotation (
          Line(points = {{6, 10}, {18, 10}}, color = {0, 0, 0}));
        connect(loadTorque.flange, outPow.flange_b) annotation (
          Line(points = {{44, 10}, {38, 10}}, color = {0, 0, 0}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-80, -60}, {80, 60}})),
          experiment(StopTime = 50),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-80, -60}, {80, 60}})),
          Documentation(info = "<html>
<p>This is a simple test of model IceConn, loaded with a huge inertia and a quadratic dependent load torque.</p>
<p>It shows that the generated power (variable icePowDel inside connectors and bus) follows the power request. The load power outPow.Power differs from the generated power due to the large inertia in-between. If closer matching between icePowDel and powReq.y is wanted the ice inner control gain contrGain can be raised.</p>
<p>It shows also the fuel consumption output. The user could also have a look at the rotational speed. </p>
</html>"));
      end TestIceConn;

      model TestOneFlangeConn
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5, phi(start = 0, fixed = true), w(start = 50, fixed = true)) annotation (
          Placement(transformation(extent = {{38, 0}, {58, 20}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque loadTorque(tau_nominal = -50, w_nominal = 400) annotation (
          Placement(transformation(extent = {{92, 0}, {72, 20}})));
        Modelica.Electrical.Analog.Sources.ConstantVoltage gen(V = 100) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {-64, 10})));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(transformation(extent = {{-90, -20}, {-70, 0}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powMech annotation (
          Placement(transformation(extent = {{12, 0}, {32, 20}})));
        Modelica.Electrical.Analog.Sensors.PowerSensor powElec annotation (
          Placement(transformation(extent = {{-52, 14}, {-32, 34}})));
        OneFlangeConn oneFlangeConn(powMax = 10000, tauMax = 50, J = 0.5, wMax = 300, mapsFileName = "EVmaps.txt", effMapName = "effTable") annotation (
          Placement(transformation(extent = {{-16, 0}, {4, 20}})));
        SupportModels.ConnectorRelated.ToConnGenTauRef toConnGenTauNorm annotation (
          Placement(transformation(extent = {{-16, -34}, {-4, -22}})));
        Modelica.Blocks.Sources.Trapezoid tauRef(rising = 10, width = 10, falling = 10, period = 1e6, startTime = 10, amplitude = 50, offset = 20) annotation (
          Placement(transformation(extent = {{-48, -38}, {-28, -18}})));
      equation
        connect(inertia.flange_b, loadTorque.flange) annotation (
          Line(points = {{58, 10}, {72, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(ground.p, gen.n) annotation (
          Line(points = {{-80, 0}, {-64, 0}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(inertia.flange_a, powMech.flange_b) annotation (
          Line(points = {{38, 10}, {32, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(powElec.pc, gen.p) annotation (
          Line(points = {{-52, 24}, {-64, 24}, {-64, 20}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.pv, powElec.nc) annotation (
          Line(points = {{-42, 34}, {-36, 34}, {-36, 34}, {-32, 34}, {-32, 24}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powMech.flange_a, oneFlangeConn.flange_a) annotation (
          Line(points = {{12, 10}, {4, 10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(oneFlangeConn.pin_p, powElec.nc) annotation (
          Line(points = {{-2, 20}, {-24, 20}, {-24, 24}, {-32, 24}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(oneFlangeConn.pin_n, gen.n) annotation (
          Line(points = {{-11.8, 20}, {-24, 20}, {-24, 0}, {-64, 0}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(toConnGenTauNorm.conn, oneFlangeConn.conn) annotation (
          Line(points = {{-4.2, -28}, {4, -28}, {4, 2.2}}, color = {255, 204, 51}, thickness = 0.5, smooth = Smooth.None));
        connect(powElec.nv, gen.n) annotation (
          Line(points = {{-42, 14}, {-42, 0}, {-64, 0}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(toConnGenTauNorm.u, tauRef.y) annotation (
          Line(points = {{-17, -28}, {-27, -28}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 60}}), graphics),
          experiment(StopTime = 50),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})),
          Documentation(info = "<html>
<p>This is a simple test of model OneFlange with bus connector.</p>
<p>For the description see the description of TestOneFlange (substitute the word &QUOT;oneFlange&QUOT; with &QUOT;oneFlangeConn&QUOT;).</p>
</html>"));
      end TestOneFlangeConn;

      model TestTwoFlange "Test of TwoFlange drive train model"
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5, phi(start = 0, fixed = true), w(start = 50, fixed = true)) annotation (
          Placement(transformation(extent = {{38, -10}, {58, 10}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque loadTorque(w_nominal = 400, tau_nominal = -50.0) annotation (
          Placement(transformation(extent = {{92, -10}, {72, 10}})));
        Modelica.Electrical.Analog.Sources.ConstantVoltage gen(V = 100) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {-60, 28})));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(transformation(extent = {{-100, -2}, {-80, 18}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powMech2 annotation (
          Placement(transformation(extent = {{12, -10}, {32, 10}})));
        Modelica.Electrical.Analog.Sensors.PowerSensor powElec annotation (
          Placement(transformation(extent = {{-48, 32}, {-28, 52}})));
        TwoFlange twoFlanges(J = 0.5, wMax = 300, tauMax = 60, powMax = 22000, mapsFileName = "EVmaps.txt", effMapName = "effTable") annotation (
          Placement(transformation(extent = {{-18, -10}, {2, 10}})));
        Modelica.Mechanics.Rotational.Sources.ConstantTorque tau1(tau_constant = -5.0) annotation (
          Placement(transformation(extent = {{-76, -10}, {-56, 10}})));
        Modelica.Mechanics.Rotational.Sensors.PowerSensor powMech1 annotation (
          Placement(transformation(extent = {{-28, -10}, {-48, 10}})));
        Modelica.Blocks.Sources.Trapezoid tauRef(rising = 10, width = 10, falling = 10, period = 1e6, startTime = 10, amplitude = 50, offset = 20) annotation (
          Placement(transformation(extent = {{-40, -48}, {-20, -28}})));
      equation
        connect(inertia.flange_b, loadTorque.flange) annotation (
          Line(points = {{58, 0}, {72, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(ground.p, gen.n) annotation (
          Line(points = {{-90, 18}, {-60, 18}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(inertia.flange_a, powMech2.flange_b) annotation (
          Line(points = {{38, 0}, {32, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(powElec.pc, gen.p) annotation (
          Line(points = {{-48, 42}, {-60, 42}, {-60, 38}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.pv, powElec.nc) annotation (
          Line(points = {{-38, 52}, {-28, 52}, {-28, 42}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powMech2.flange_a, twoFlanges.flange_b) annotation (
          Line(points = {{12, 0}, {8, 0}, {8, -0.2}, {2, -0.2}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(powElec.nc, twoFlanges.pin_n) annotation (
          Line(points = {{-28, 42}, {-4, 42}, {-4, 10}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(twoFlanges.pin_p, gen.n) annotation (
          Line(points = {{-12, 9.8}, {-12, 18}, {-60, 18}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(powElec.nv, gen.n) annotation (
          Line(points = {{-38, 32}, {-38, 18}, {-60, 18}}, color = {0, 0, 255}, smooth = Smooth.None));
        connect(twoFlanges.flange_a, powMech1.flange_a) annotation (
          Line(points = {{-18, 0}, {-28, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(tau1.flange, powMech1.flange_b) annotation (
          Line(points = {{-56, 0}, {-48, 0}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(tauRef.y, twoFlanges.tauRef) annotation (
          Line(points = {{-19, -38}, {-8, -38}, {-8, -9.2}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -60}, {100, 60}})),
          experiment(StopTime = 50),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})),
          Documentation(info = "<html>
<p>This is a simple test of model TwoFlange. </p>
<p>It shows that the generated torque follows the normalised torque request as long as it does not overcome torque and power limits. The generated torque will act on the machine inertia in conjunction with the torques applied from the exterior to the two flanges. </p>
<p>It shows also the effects of efficiency on the DC power. </p>
<p>First suggested plots: a plot with tauRef.y and twoFlanges.inertia.flange_a.tau; with the same axes another plot with twoFlanges.limTau.powLimActive and twoFlanges.limTau.powLimActive. In these plots it can be seen that: </p>
<p>&middot;<span style=\"font-size: 7pt;\">&nbsp; </span>during the first 18 seconds the generated torque equals the torque request tauRef.y </p>
<p>&middot;<span style=\"font-size: 7pt;\">&nbsp; </span>between 18 and 21 s the maximum torque limit is reached, but not the maximum power limit </p>
<p>&middot;<span style=\"font-size: 7pt;\">&nbsp; </span>between 21 and 33 s the maximum power occurs </p>
<p>&middot;<span style=\"font-size: 7pt;\">&nbsp; </span>after 33s, the requested torque is delivered. </p>
<p>Second suggested plot: once the first plots are analysed, the user might want to have an idea of the mechanical and electrical powers: these are seen putting in the same plot (powMech1.power+powMech2.power) and powElec.power. </p>
</html>"));
      end TestTwoFlange;
    end TestingModels;

    package ECUs
      model Ecu1 "Power Split hybrid power train controller, not using ON/OFF strategy"
        parameter Real genTorqueMax = 80 "maximum absolute value of gen torque (Nm)";
        parameter Real maxTorqueReq = 80 "Torque request (Nm) that corresponds to 1 from driver";
        parameter Real powFiltT = 60 "Power filter time constant (s)";
        parameter Real genLoopGain = 0.1 "Control gain between ice speed error and gen torque: Nm/(rad/s)";
        Modelica.Blocks.Interfaces.RealInput tauRef annotation (
          Placement(visible = true, transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder powFilt(T = powFiltT) annotation (
          Placement(visible = true, transformation(origin = {-40, 40}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        SupportModels.ConnectorRelated.Conn conn1 annotation (
          Placement(visible = true, transformation(extent = {{-20, 60}, {20, 100}}, rotation = 0), iconTransformation(extent = {{-20, 78}, {20, 118}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = genLoopGain) annotation (
          Placement(visible = true, transformation(extent = {{32, -30}, {52, -10}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{6, -10}, {26, -30}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limiter(uMax = genTorqueMax, uMin = -genTorqueMax) annotation (
          Placement(visible = true, transformation(origin = {60, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Tables.CombiTable1Ds powToW(fileName = "wToTau.txt", tableOnFile = false, table = [0, 0; 1884, 126; 9800, 126; 36600, 366; 52300, 523]) "optimal ice speed as a function of power" annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-40, -20})));
        Modelica.Blocks.Math.Gain toNm(k = maxTorqueReq) "converts p.u. torque request into Nm" annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-80, 32})));
        Modelica.Blocks.Nonlinear.Limiter limiter1(uMax = 1e6, uMin = 125) annotation (
          Placement(visible = true, transformation(origin = {-10, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder genTauFilt(T = 1) annotation (
          Placement(visible = true, transformation(origin = {60, 12}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
      equation
        connect(powFilt.u, conn1.motPowDelB) annotation (
          Line(points = {{-40, 52}, {-40, 60}, {0, 60}, {0, 80}}, color = {0, 0, 127}));
        connect(powFilt.y, conn1.icePowRef) annotation (
          Line(points = {{-40, 29}, {-40, 20}, {0, 20}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(gain.u, feedback.y) annotation (
          Line(points = {{30, -20}, {25, -20}}, color = {0, 0, 127}));
        connect(powToW.u, powFilt.y) annotation (
          Line(points = {{-52, -20}, {-60, -20}, {-60, 20}, {-40, 20}, {-40, 29}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(feedback.u2, conn1.iceW) annotation (
          Line(points = {{16, -12}, {16, 40}, {16, 40}, {16, 66}, {0, 66}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(limiter.y, conn1.genTauRef) annotation (
          Line(points = {{60, 51}, {60, 74}, {0, 74}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(toNm.u, tauRef) annotation (
          Line(points = {{-80, 20}, {-80, 0}, {-120, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toNm.y, conn1.motTauRef) annotation (
          Line(points = {{-80, 43}, {-80, 80}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(feedback.u1, limiter1.y) annotation (
          Line(points = {{8, -20}, {1, -20}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(limiter1.u, powToW.y[1]) annotation (
          Line(points = {{-22, -20}, {-29, -20}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(limiter.u, genTauFilt.y) annotation (
          Line(points = {{60, 28}, {60, 23}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(genTauFilt.u, gain.y) annotation (
          Line(points = {{60, 0}, {60, -20}, {53, -20}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1), graphics = {Text(extent = {{-82, 74}, {-24, 70}}, textString = "Send requested torque to mot"), Text(extent = {{-22, 16}, {6, 12}}, textString = "send filtered 
power to ice"), Text(extent = {{62, 70}, {94, 60}}, textString = "send 
reference tau
to gen", horizontalAlignment = TextAlignment.Left)}),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(lineColor = {0, 0, 255}, extent = {{-100, -102}, {100, -140}}, textString = "%name"), Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-4, -40}, {74, 16}, {74, -6}, {-4, -62}, {-4, -40}}, lineColor = {95, 95, 95}, fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid), Polygon(points = {{8, -38}, {28, -48}, {20, -54}, {0, -44}, {8, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -54}, {28, -48}, {32, -56}, {24, -62}, {20, -54}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{24, -62}, {32, -56}, {32, -78}, {24, -84}, {24, -62}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{0, -44}, {20, -54}, {24, -62}, {24, -84}, {22, -84}, {22, -62}, {20, -58}, {0, -48}, {0, -44}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-14, 40}, {-18, 32}, {-10, 38}, {-8, 44}, {-14, 40}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-18, 32}, {-10, 38}, {-10, 14}, {-18, 8}, {-18, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-20, 10}, {-20, 32}, {-16, 40}, {4, 30}, {4, 26}, {-16, 36}, {-18, 32}, {-18, 8}, {-20, 10}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-8, 46}, {12, 36}, {4, 30}, {-16, 40}, {-8, 46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{28, -22}, {48, -32}, {40, -38}, {20, -28}, {28, -22}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -38}, {48, -32}, {52, -40}, {44, -46}, {40, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{44, -46}, {52, -40}, {52, -62}, {44, -68}, {44, -46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -28}, {40, -38}, {44, -46}, {44, -68}, {42, -68}, {42, -46}, {40, -42}, {20, -32}, {20, -28}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{48, -8}, {68, -18}, {60, -24}, {40, -14}, {48, -8}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{60, -24}, {68, -18}, {72, -26}, {64, -32}, {60, -24}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{64, -32}, {72, -26}, {72, -48}, {64, -54}, {64, -32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -14}, {60, -24}, {64, -32}, {64, -54}, {62, -54}, {62, -32}, {60, -28}, {40, -18}, {40, -14}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{68, 6}, {88, -4}, {80, -10}, {60, 0}, {68, 6}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{80, -10}, {88, -4}, {92, -12}, {84, -18}, {80, -10}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{84, -18}, {92, -12}, {92, -34}, {84, -40}, {84, -18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{60, 0}, {80, -10}, {84, -18}, {84, -40}, {82, -40}, {82, -18}, {80, -14}, {60, -4}, {60, 0}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-34, 26}, {-38, 18}, {-30, 24}, {-28, 30}, {-34, 26}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-38, 18}, {-30, 24}, {-30, 0}, {-38, -6}, {-38, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-40, -4}, {-40, 18}, {-36, 26}, {-16, 16}, {-16, 12}, {-36, 22}, {-38, 18}, {-38, -6}, {-40, -4}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 32}, {-8, 22}, {-16, 16}, {-36, 26}, {-28, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-54, 12}, {-58, 4}, {-50, 10}, {-48, 16}, {-54, 12}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-58, 4}, {-50, 10}, {-50, -14}, {-58, -20}, {-58, 4}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-60, -18}, {-60, 4}, {-56, 12}, {-36, 2}, {-36, -2}, {-56, 8}, {-58, 4}, {-58, -20}, {-60, -18}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-48, 18}, {-28, 8}, {-36, 2}, {-56, 12}, {-48, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-74, -4}, {-78, -12}, {-70, -6}, {-68, 0}, {-74, -4}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-78, -12}, {-70, -6}, {-70, -30}, {-78, -36}, {-78, -12}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-80, -34}, {-80, -12}, {-76, -4}, {-56, -14}, {-56, -18}, {-76, -8}, {-78, -12}, {-78, -36}, {-80, -34}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-68, 2}, {-48, -8}, {-56, -14}, {-76, -4}, {-68, 2}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {-4, -62}, {-64, -30}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {74, 16}, {14, 48}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {160, 160, 164}, fillPattern = FillPattern.Solid), Rectangle(extent = {{-98, 92}, {98, 62}}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, pattern = LinePattern.None), Text(extent = {{-100, 84}, {100, 54}}, lineColor = {0, 0, 0}, textString = "PSD-ecu1")}),
          Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Power Split Power Train Controller without ON/OFF</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This controller operates as follows:</span></p>
<ul>
<li><span style=\"font-family: MS Shell Dlg 2;\">it makes the ice deliver the average power needed by the power train</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">it determines the optimal ice speed at which the requested power is delivered with minimum fuel consumption and asks the &QUOT;gen&QUOT; to control so that the ice opertes at that speed</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">the vehicle motion is controlled acting on the &QUOT;mot&QUOT;.</span></li>
</ul>
<p><span style=\"font-family: MS Shell Dlg 2;\"></p><p>Since this technique allows only approximatively the correct energy balance of the vehicle, the battery tends to sdischarge.This is solved with MBEcu2, in which a closed loop StateOfCharge (SOC) control is added.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">So:</span></p>
<ul>
<li><span style=\"font-family: MS Shell Dlg 2;\">powFilt Block filters the delivered power to obtained the power to ask the ICE to deliver</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">toIceWref converts the power to be requested from the ICE by its maximum torque at the actual speed</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">after a limiting block, this torque is the reference signal of a feedback; the corresponnding error controls the Gen torque.</span></li>
</ul>
</html>"));
      end Ecu1;

      model Ecu2 "Power Split hybrid power train controller, with SOC control, without ON/OFF"
        parameter Modelica.SIunits.Torque genTorqueMax = 80 "maximum absolute valoe of gen torque";
        parameter Real socRef = 0.6 "Target value of SOC";
        parameter Modelica.SIunits.Power socLoopGain = 10000 "soc loop gain";
        parameter Modelica.SIunits.Torque maxTorqueReq = 80 "Torque request (Nm) that corresponds to 1 from driver";
        parameter Real genLoopGain(unit = "N.m/(rad/s)") = 0.1 "Control gain between ICE speed error and gen torque";
        parameter Modelica.SIunits.Time powFiltT = 60 "Power filter time constant (s)";
        Modelica.Blocks.Interfaces.RealInput tauReference annotation (
          Placement(visible = true, transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder powFilt(T = powFiltT) annotation (
          Placement(visible = true, transformation(origin = {20, 46}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        SupportModels.ConnectorRelated.Conn conn1 annotation (
          Placement(visible = true, transformation(extent = {{-20, 60}, {20, 100}}, rotation = 0), iconTransformation(extent = {{-20, 78}, {20, 118}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = genLoopGain) annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {84, -4})));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{36, -30}, {56, -50}}, rotation = 0)));
        Modelica.Blocks.Tables.CombiTable1Ds toIceWref(fileName = "wToTau.txt", tableOnFile = false, table = [0, 0; 1884, 126; 9800, 126; 36600, 366; 52300, 523]) "optimal ice speed as a function of power" annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-16, -40})));
        Modelica.Blocks.Math.Gain toNm(k = maxTorqueReq) "converts p.u. torque request into Nm" annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-86, 30})));
        Modelica.Blocks.Nonlinear.Limiter limiter1(uMax = 1e6, uMin = 125) annotation (
          Placement(visible = true, transformation(origin = {14, -40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder genTauFilt(T = 1) annotation (
          Placement(visible = true, transformation(origin = {84, 38}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Add add annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {18, 8})));
        Modelica.Blocks.Math.Feedback fbSOC annotation (
          Placement(transformation(extent = {{-50, 38}, {-30, 18}})));
        Modelica.Blocks.Math.Gain socErrToPow(k = socLoopGain) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-10, 28})));
        Modelica.Blocks.Sources.Constant socRef_(k = socRef) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-54, -2})));
      equation
        connect(powFilt.u, conn1.motPowDelB) annotation (
          Line(points = {{20, 58}, {20, 58}, {20, 64}, {20, 64}, {0, 64}, {0, 80}}, color = {0, 0, 127}));
        connect(gain.u, feedback.y) annotation (
          Line(points = {{84, -16}, {84, -16}, {84, -40}, {82, -40}, {56, -40}, {56, -40}, {55, -40}}, color = {0, 0, 127}));
        connect(feedback.u2, conn1.iceW) annotation (
          Line(points = {{46, -32}, {46, 4}, {40, 4}, {40, 64}, {0, 64}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(toNm.u, tauReference) annotation (
          Line(points = {{-86, 18}, {-86, 0}, {-120, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toNm.y, conn1.motTauRef) annotation (
          Line(points = {{-86, 41}, {-86, 80}, {0, 80}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(feedback.u1, limiter1.y) annotation (
          Line(points = {{38, -40}, {25, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(limiter1.u, toIceWref.y[1]) annotation (
          Line(points = {{2, -40}, {-5, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(genTauFilt.u, gain.y) annotation (
          Line(points = {{84, 26}, {84, 7}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(powFilt.y, add.u1) annotation (
          Line(points = {{20, 35}, {20, 26}, {24, 26}, {24, 20}}, color = {0, 0, 127}));
        connect(socErrToPow.y, add.u2) annotation (
          Line(points = {{1, 28}, {12, 28}, {12, 20}}, color = {0, 0, 127}));
        connect(fbSOC.y, socErrToPow.u) annotation (
          Line(points = {{-31, 28}, {-22, 28}}, color = {0, 0, 127}));
        connect(add.y, toIceWref.u) annotation (
          Line(points = {{18, -3}, {18, -3}, {18, -10}, {18, -12}, {18, -18}, {-40, -18}, {-40, -40}, {-28, -40}}, color = {0, 0, 127}));
        connect(fbSOC.u2, conn1.batSOC) annotation (
          Line(points = {{-40, 36}, {-40, 36}, {-40, 80}, {0, 80}}, color = {0, 0, 127}),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(socRef_.y, fbSOC.u1) annotation (
          Line(points = {{-54, 9}, {-54, 28}, {-48, 28}}, color = {0, 0, 127}));
        connect(add.y, conn1.icePowRef) annotation (
          Line(points = {{18, -3}, {18, -3}, {18, -18}, {18, -12}, {56, -12}, {56, 74}, {0, 74}, {0, 80}}, color = {0, 0, 127}),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(genTauFilt.y, conn1.genTauRef) annotation (
          Line(points = {{84, 49}, {84, 49}, {84, 80}, {0, 80}}, color = {0, 0, 127}),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Diagram(coordinateSystem(extent = {{-100, -60}, {100, 80}}, preserveAspectRatio = false, initialScale = 0.1), graphics = {Text(extent = {{-84, 68}, {-70, 56}}, textString = "Send 
requested
torque 
to mot", horizontalAlignment = TextAlignment.Left), Text(extent = {{54, 68}, {82, 58}}, textString = "send 
reference tau
to gen", horizontalAlignment = TextAlignment.Right), Text(extent = {{28, 66}, {54, 54}}, textString = "send 
ref pow
to ice", horizontalAlignment = TextAlignment.Right)}),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(lineColor = {0, 0, 255}, extent = {{-100, -102}, {100, -140}}, textString = "%name"), Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-4, -40}, {74, 16}, {74, -6}, {-4, -62}, {-4, -40}}, lineColor = {95, 95, 95}, fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid), Polygon(points = {{8, -38}, {28, -48}, {20, -54}, {0, -44}, {8, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -54}, {28, -48}, {32, -56}, {24, -62}, {20, -54}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{24, -62}, {32, -56}, {32, -78}, {24, -84}, {24, -62}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{0, -44}, {20, -54}, {24, -62}, {24, -84}, {22, -84}, {22, -62}, {20, -58}, {0, -48}, {0, -44}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-14, 40}, {-18, 32}, {-10, 38}, {-8, 44}, {-14, 40}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-18, 32}, {-10, 38}, {-10, 14}, {-18, 8}, {-18, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-20, 10}, {-20, 32}, {-16, 40}, {4, 30}, {4, 26}, {-16, 36}, {-18, 32}, {-18, 8}, {-20, 10}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-8, 46}, {12, 36}, {4, 30}, {-16, 40}, {-8, 46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{28, -22}, {48, -32}, {40, -38}, {20, -28}, {28, -22}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -38}, {48, -32}, {52, -40}, {44, -46}, {40, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{44, -46}, {52, -40}, {52, -62}, {44, -68}, {44, -46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -28}, {40, -38}, {44, -46}, {44, -68}, {42, -68}, {42, -46}, {40, -42}, {20, -32}, {20, -28}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{48, -8}, {68, -18}, {60, -24}, {40, -14}, {48, -8}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{60, -24}, {68, -18}, {72, -26}, {64, -32}, {60, -24}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{64, -32}, {72, -26}, {72, -48}, {64, -54}, {64, -32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -14}, {60, -24}, {64, -32}, {64, -54}, {62, -54}, {62, -32}, {60, -28}, {40, -18}, {40, -14}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{68, 6}, {88, -4}, {80, -10}, {60, 0}, {68, 6}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{80, -10}, {88, -4}, {92, -12}, {84, -18}, {80, -10}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{84, -18}, {92, -12}, {92, -34}, {84, -40}, {84, -18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{60, 0}, {80, -10}, {84, -18}, {84, -40}, {82, -40}, {82, -18}, {80, -14}, {60, -4}, {60, 0}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-34, 26}, {-38, 18}, {-30, 24}, {-28, 30}, {-34, 26}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-38, 18}, {-30, 24}, {-30, 0}, {-38, -6}, {-38, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-40, -4}, {-40, 18}, {-36, 26}, {-16, 16}, {-16, 12}, {-36, 22}, {-38, 18}, {-38, -6}, {-40, -4}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 32}, {-8, 22}, {-16, 16}, {-36, 26}, {-28, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-54, 12}, {-58, 4}, {-50, 10}, {-48, 16}, {-54, 12}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-58, 4}, {-50, 10}, {-50, -14}, {-58, -20}, {-58, 4}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-60, -18}, {-60, 4}, {-56, 12}, {-36, 2}, {-36, -2}, {-56, 8}, {-58, 4}, {-58, -20}, {-60, -18}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-48, 18}, {-28, 8}, {-36, 2}, {-56, 12}, {-48, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-74, -4}, {-78, -12}, {-70, -6}, {-68, 0}, {-74, -4}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-78, -12}, {-70, -6}, {-70, -30}, {-78, -36}, {-78, -12}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-80, -34}, {-80, -12}, {-76, -4}, {-56, -14}, {-56, -18}, {-76, -8}, {-78, -12}, {-78, -36}, {-80, -34}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-68, 2}, {-48, -8}, {-56, -14}, {-76, -4}, {-68, 2}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {-4, -62}, {-64, -30}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {74, 16}, {14, 48}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {160, 160, 164}, fillPattern = FillPattern.Solid), Rectangle(extent = {{-98, 92}, {98, 62}}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, pattern = LinePattern.None), Text(extent = {{-100, 82}, {100, 54}}, lineColor = {0, 0, 0}, textString = "PSD-ecu2")}),
          Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Power Split Power Train Controller without ON/OFF</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This controller is derived from MBecu1, in which the basic description can be found.</span></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">It adds a soc control loop to avoid soc Drifts.</span></p>
</html>"));
      end Ecu2;

      model Ecu3 "Power Split hybrid power train controller, using ON/OFF strategy"
        parameter Real socRef = 0.6 "Reference soc";
        parameter Real maxTorqueReq = 80 "Maximum torque that can be requested from mot";
        parameter Real powFiltT = 60 "Power filter time constant (s)";
        parameter Real socLoopGain = 50e3 "gain of the soc loop (w/pu)";
        parameter Real genLoopGain = 0.02 "gain of the soc loop (Nm/(rad/s))";
        parameter Real onThreshold = 7000 "average power over which engine is switched on (W)";
        parameter Real offThreshold = 5000 "average power below which engine is switched off (W)";
        Modelica.Blocks.Interfaces.RealInput tauReference annotation (
          Placement(visible = true, transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder powFilt(T = powFiltT) annotation (
          Placement(visible = true, transformation(origin = {-50, 58}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        SupportModels.ConnectorRelated.Conn conn annotation (
          Placement(visible = true, transformation(extent = {{-20, 78}, {20, 118}}, rotation = 0), iconTransformation(extent = {{-20, 78}, {20, 118}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = genLoopGain) annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {104, 30})));
        Modelica.Blocks.Math.Gain toNm(k = maxTorqueReq) "converts p.u. torque request into Nm" annotation (
          Placement(visible = true, transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-88, 50})));
        Modelica.Blocks.Continuous.FirstOrder genTauFilt(T = 1) annotation (
          Placement(visible = true, transformation(origin = {104, 76}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
        Modelica.Blocks.Math.Add add annotation (
          Placement(visible = true, transformation(origin = {-36, 12}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Tables.CombiTable1Ds powToW(fileName = "wToTau.txt", tableOnFile = false, table = [0, 0; 1884, 126; 9800, 126; 36600, 366; 52300, 523]) "optimal ice speed as a function of power" annotation (
          Placement(visible = true, transformation(origin = {64, -16}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Nonlinear.Limiter iceSpeedLimiter(uMax = 1e6, uMin = 125) annotation (
          Placement(visible = true, transformation(origin = {64, 16}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{-10, 10}, {10, -10}}, rotation = 90, origin = {64, 46})));
        Modelica.Blocks.Sources.Constant socRef_(k = socRef) annotation (
          Placement(visible = true, transformation(extent = {{-98, -34}, {-78, -14}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback fbSOC annotation (
          Placement(visible = true, transformation(extent = {{-74, -14}, {-54, -34}}, rotation = 0)));
        Modelica.Blocks.Math.Gain socErrrToPow(k = socLoopGain) annotation (
          Placement(visible = true, transformation(origin = {-38, -24}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Logical.Hysteresis hysteresis(uLow = offThreshold, uHigh = onThreshold) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-18, 42})));
        Modelica.Blocks.Logical.Switch switch1 annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {12, 12})));
        Modelica.Blocks.Sources.Constant constZero(k = 0) annotation (
          Placement(transformation(extent = {{20, -30}, {0, -10}})));
      equation
        connect(socErrrToPow.y, add.u2) annotation (
          Line(points = {{-27, -24}, {-22, -24}, {-22, -4}, {-58, -4}, {-58, 6}, {-48, 6}}, color = {0, 0, 127}));
        connect(socErrrToPow.u, fbSOC.y) annotation (
          Line(points = {{-50, -24}, {-55, -24}}, color = {0, 0, 127}));
        connect(fbSOC.u2, conn.batSOC) annotation (
          Line(points = {{-64, -16}, {-64, -12}, {-68, -12}, {-68, 98}, {0, 98}}, color = {0, 0, 127}));
        connect(fbSOC.u1, socRef_.y) annotation (
          Line(points = {{-72, -24}, {-77, -24}}, color = {0, 0, 127}));
        connect(feedback.u1, iceSpeedLimiter.y) annotation (
          Line(points = {{64, 38}, {64, 38}, {64, 28}, {64, 27}}, color = {0, 0, 127}));
        connect(feedback.u2, conn.iceW) annotation (
          Line(points = {{56, 46}, {56, 72}, {56, 98}, {0, 98}}, color = {0, 0, 127}));
        connect(gain.u, feedback.y) annotation (
          Line(points = {{104, 18}, {104, 18}, {104, 0}, {88, 0}, {88, 55}, {64, 55}}, color = {0, 0, 127}));
        connect(iceSpeedLimiter.u, powToW.y[1]) annotation (
          Line(points = {{64, 4}, {64, -5}}, color = {0, 0, 127}));
        connect(add.u1, powFilt.y) annotation (
          Line(points = {{-48, 18}, {-54, 18}, {-58, 18}, {-58, 42}, {-50, 42}, {-50, 47}}, color = {0, 0, 127}));
        connect(powFilt.u, conn.motPowDelB) annotation (
          Line(points = {{-50, 70}, {-50, 78}, {0, 78}, {0, 98}}, color = {0, 0, 127}));
        connect(toNm.u, tauReference) annotation (
          Line(points = {{-88, 38}, {-88, 0}, {-120, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toNm.y, conn.motTauRef) annotation (
          Line(points = {{-88, 61}, {-88, 98}, {0, 98}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(gain.y, genTauFilt.u) annotation (
          Line(points = {{104, 41}, {104, 64}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(genTauFilt.y, conn.genTauRef) annotation (
          Line(points = {{104, 87}, {104, 98}, {0, 98}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(hysteresis.u, add.y) annotation (
          Line(points = {{-18, 30}, {-18, 12}, {-25, 12}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(hysteresis.y, conn.iceON) annotation (
          Line(points = {{-18, 53}, {-18, 92}, {0, 92}, {0, 98}}, color = {255, 0, 255}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        connect(powToW.u, switch1.y) annotation (
          Line(points = {{64, -28}, {30, -28}, {30, 12}, {23, 12}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(switch1.u1, add.y) annotation (
          Line(points = {{0, 20}, {-18, 20}, {-18, 12}, {-25, 12}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(switch1.u3, constZero.y) annotation (
          Line(points = {{0, 4}, {-8, 4}, {-8, -20}, {-1, -20}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(switch1.u2, hysteresis.y) annotation (
          Line(points = {{0, 12}, {-8, 12}, {-8, 30}, {0, 30}, {0, 62}, {-18, 62}, {-18, 53}}, color = {255, 0, 255}, smooth = Smooth.None));
        connect(powToW.u, conn.icePowRef) annotation (
          Line(points = {{64, -28}, {30, -28}, {30, 72}, {0, 72}, {0, 98}}, color = {0, 0, 127}, smooth = Smooth.None),
          Text(string = "%second", index = 1, extent = {{6, 3}, {6, 3}}));
        annotation (
          Documentation(info = "<html>
<p><b><span style=\"font-family: MS Shell Dlg 2;\">Power Split Power Train Controller with ON/OFF</span></b></p>
<p><span style=\"font-family: MS Shell Dlg 2;\">This controller operates as follows:</span></p>
<ul>
<li><span style=\"font-family: MS Shell Dlg 2;\">it makes the ice deliver the average power needed by the power train</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">it determines the optimal ice speed at which the requested power is delivered with minimum fuel consumption and asks the &QUOT;gen&QUOT; to control so that the ice opertes at that speed</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">the vehicle motion is controlled acting on the &QUOT;mot&QUOT;.</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">a closed-loop SOC control avoids the battery do become too charged or discharged</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">an ON/OFF control determines ICe switching OFF when the looad is to loow and switching it ON again when the requested power is sifnigicntly high. this normally reduces fuel consumpton.</span></li>
</ul>
<p><span style=\"font-family: MS Shell Dlg 2;\">So:</span></p>
<ul>
<li><span style=\"font-family: MS Shell Dlg 2;\">powFilt Block filters the delivered power to obtained the power to ask the ICE to deliver</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">toIceWref converts the power to be requested from the ICE by its maximum torque at the actual speed</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">after a limiting block, this torque is the reference signal of a feedback; the corresponnding error controls the Gen torque.</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">fbSOC sis the feedback for SOC control and socLoopGain is its gain</span></li>
<li><span style=\"font-family: MS Shell Dlg 2;\">hysteresis manages switching ON/OFF the ice. </span></li>
</ul>
<p><span style=\"font-family: MS Shell Dlg 2;\"></p><p>Details of ice going to off (e.g. bringing its speed to zero) and to on (i.e. first making ice speed to rise, then start sending fuel) are not implemented.</span></p>
</html>"),Diagram(coordinateSystem(extent = {{-100, -40}, {120, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-86, 92}, {-28, 88}}, textString = "Send requested torque to mot"), Text(extent = {{12, 50}, {40, 46}}, textString = "send reterence tau
 to gen"), Ellipse(extent = {{-44, 100}, {48, -42}}, lineColor = {255, 0, 0}, lineThickness = 0.5)}),
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(lineColor = {0, 0, 255}, extent = {{-102, -102}, {98, -140}}, textString = "%name"), Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Polygon(lineColor = {95, 95, 95}, fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid, points = {{-4, -40}, {74, 16}, {74, -6}, {-4, -62}, {-4, -40}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{8, -38}, {28, -48}, {20, -54}, {0, -44}, {8, -38}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{20, -54}, {28, -48}, {32, -56}, {24, -62}, {20, -54}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{24, -62}, {32, -56}, {32, -78}, {24, -84}, {24, -62}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{0, -44}, {20, -54}, {24, -62}, {24, -84}, {22, -84}, {22, -62}, {20, -58}, {0, -48}, {0, -44}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-14, 40}, {-18, 32}, {-10, 38}, {-8, 44}, {-14, 40}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-18, 32}, {-10, 38}, {-10, 14}, {-18, 8}, {-18, 32}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-20, 10}, {-20, 32}, {-16, 40}, {4, 30}, {4, 26}, {-16, 36}, {-18, 32}, {-18, 8}, {-20, 10}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-8, 46}, {12, 36}, {4, 30}, {-16, 40}, {-8, 46}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{28, -22}, {48, -32}, {40, -38}, {20, -28}, {28, -22}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{40, -38}, {48, -32}, {52, -40}, {44, -46}, {40, -38}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{44, -46}, {52, -40}, {52, -62}, {44, -68}, {44, -46}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{20, -28}, {40, -38}, {44, -46}, {44, -68}, {42, -68}, {42, -46}, {40, -42}, {20, -32}, {20, -28}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{48, -8}, {68, -18}, {60, -24}, {40, -14}, {48, -8}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{60, -24}, {68, -18}, {72, -26}, {64, -32}, {60, -24}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{64, -32}, {72, -26}, {72, -48}, {64, -54}, {64, -32}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{40, -14}, {60, -24}, {64, -32}, {64, -54}, {62, -54}, {62, -32}, {60, -28}, {40, -18}, {40, -14}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{68, 6}, {88, -4}, {80, -10}, {60, 0}, {68, 6}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{80, -10}, {88, -4}, {92, -12}, {84, -18}, {80, -10}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{84, -18}, {92, -12}, {92, -34}, {84, -40}, {84, -18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{60, 0}, {80, -10}, {84, -18}, {84, -40}, {82, -40}, {82, -18}, {80, -14}, {60, -4}, {60, 0}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-34, 26}, {-38, 18}, {-30, 24}, {-28, 30}, {-34, 26}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-38, 18}, {-30, 24}, {-30, 0}, {-38, -6}, {-38, 18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-40, -4}, {-40, 18}, {-36, 26}, {-16, 16}, {-16, 12}, {-36, 22}, {-38, 18}, {-38, -6}, {-40, -4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-28, 32}, {-8, 22}, {-16, 16}, {-36, 26}, {-28, 32}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-54, 12}, {-58, 4}, {-50, 10}, {-48, 16}, {-54, 12}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-58, 4}, {-50, 10}, {-50, -14}, {-58, -20}, {-58, 4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-60, -18}, {-60, 4}, {-56, 12}, {-36, 2}, {-36, -2}, {-56, 8}, {-58, 4}, {-58, -20}, {-60, -18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-48, 18}, {-28, 8}, {-36, 2}, {-56, 12}, {-48, 18}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-74, -4}, {-78, -12}, {-70, -6}, {-68, 0}, {-74, -4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-78, -12}, {-70, -6}, {-70, -30}, {-78, -36}, {-78, -12}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-80, -34}, {-80, -12}, {-76, -4}, {-56, -14}, {-56, -18}, {-76, -8}, {-78, -12}, {-78, -36}, {-80, -34}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-68, 2}, {-48, -8}, {-56, -14}, {-76, -4}, {-68, 2}}), Polygon(lineColor = {95, 95, 95}, fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid, points = {{-64, -8}, {-4, -40}, {-4, -62}, {-64, -30}, {-64, -8}}), Polygon(lineColor = {95, 95, 95}, fillColor = {160, 160, 164}, fillPattern = FillPattern.Solid, points = {{-64, -8}, {-4, -40}, {74, 16}, {14, 48}, {-64, -8}}), Rectangle(fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-98, 92}, {98, 62}}), Text(extent = {{-100, 84}, {100, 58}}, lineColor = {0, 0, 0}, textString = "PSD-ecu3")}));
      end Ecu3;

      model GMS "Genset Management System (simplified)"
        parameter Real contrGain = 0.01 "speed controller gain (throttle per rad/s)";
        parameter String mapsFileName = "maps.txt" "File name where optimal speed is stored";
        import Modelica.Constants.pi;
        Modelica.Blocks.Tables.CombiTable1D optiSpeed(tableOnFile = true, columns = {2}, tableName = "optiSpeed", fileName = mapsFileName) "gives the optimal speed as a function of requested power" annotation (
          Placement(transformation(extent = {{-42, -50}, {-22, -30}})));
        Modelica.Blocks.Math.Division division annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-30, 48})));
        Modelica.Blocks.Interfaces.RealInput Wmecc annotation (
          Placement(transformation(extent = {{-15, -15}, {15, 15}}, rotation = 90, origin = {1, -115}), iconTransformation(extent = {{-15, -15}, {15, 15}}, rotation = 90, origin = {1, -115})));
        Modelica.Blocks.Interfaces.RealInput pRef annotation (
          Placement(transformation(extent = {{-134, -20}, {-94, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealOutput tRef "Torque request (positive when ICE delivers power)" annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}}), iconTransformation(extent = {{100, 50}, {120, 70}})));
        Modelica.Blocks.Interfaces.RealOutput throttle annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}}), iconTransformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(transformation(extent = {{24, -50}, {44, -30}})));
        Modelica.Blocks.Math.Gain gain(k = 0.01) annotation (
          Placement(transformation(extent = {{66, -50}, {86, -30}})));
        Modelica.Blocks.Math.UnitConversions.To_rpm to_rpm annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {34, -70})));
        Modelica.Blocks.Tables.CombiTable1D maxTau(columns = {2}, extrapolation = Modelica.Blocks.Types.Extrapolation.HoldLastPoint, fileName = mapsFileName, tableName = "maxIceTau", tableOnFile = true) "gives the optimal spees ad a function of requested power" annotation (
          Placement(transformation(extent = {{6, 68}, {26, 88}})));
        Modelica.Blocks.Nonlinear.VariableLimiter tauLimiter annotation (
          Placement(transformation(extent = {{48, 50}, {68, 70}})));
        Modelica.Blocks.Math.Gain gain1(k = -1) annotation (
          Placement(transformation(extent = {{20, 28}, {36, 44}})));
      equation
        connect(division.u1, optiSpeed.u[1]) annotation (
          Line(points = {{-36, 36}, {-36, 0}, {-60, 0}, {-60, -40}, {-44, -40}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(optiSpeed.u[1], pRef) annotation (
          Line(points = {{-44, -40}, {-60, -40}, {-60, 0}, {-114, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(throttle, gain.y) annotation (
          Line(points = {{110, -60}, {98, -60}, {98, -40}, {87, -40}}, color = {0, 0, 127}));
        connect(feedback.y, gain.u) annotation (
          Line(points = {{43, -40}, {64, -40}}, color = {0, 0, 127}));
        connect(feedback.u1, optiSpeed.y[1]) annotation (
          Line(points = {{26, -40}, {4, -40}, {-21, -40}}, color = {0, 0, 127}));
        connect(to_rpm.y, feedback.u2) annotation (
          Line(points = {{34, -59}, {34, -59}, {34, -48}}, color = {0, 0, 127}));
        connect(to_rpm.u, Wmecc) annotation (
          Line(points = {{34, -82}, {34, -94}, {1, -94}, {1, -115}}, color = {0, 0, 127}));
        connect(division.u2, Wmecc) annotation (
          Line(points = {{-24, 36}, {-24, 0}, {-6, 0}, {-6, -96}, {1, -96}, {1, -115}}, color = {0, 0, 127}));
        connect(tauLimiter.y, tRef) annotation (
          Line(points = {{69, 60}, {84, 60}, {110, 60}}, color = {0, 0, 127}));
        connect(tauLimiter.limit1, maxTau.y[1]) annotation (
          Line(points = {{46, 68}, {36, 68}, {36, 78}, {27, 78}}, color = {0, 0, 127}));
        connect(maxTau.u[1], Wmecc) annotation (
          Line(points = {{4, 78}, {0, 78}, {0, -115}, {1, -115}}, color = {0, 0, 127}));
        connect(division.y, tauLimiter.u) annotation (
          Line(points = {{-30, 59}, {-32, 59}, {-32, 60}, {46, 60}}, color = {0, 0, 127}));
        connect(gain1.y, tauLimiter.limit2) annotation (
          Line(points = {{36.8, 36}, {40, 36}, {40, 34}, {40, 52}, {46, 52}}, color = {0, 0, 127}));
        connect(gain1.u, maxTau.y[1]) annotation (
          Line(points = {{18.4, 36}, {12, 36}, {12, 54}, {36, 54}, {36, 78}, {27, 78}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          experiment(StopTime = 3, Interval = 0.01),
          experimentSetupOutput,
          Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Text(origin = {-2, 0}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-98, 22}, {98, -16}}, textString = "%name")}),
          Documentation(info = "<html>
<p>Genset Management System.</p>
<p>The control logic commands the genset to deliver at the DC port the input power, using the optimal generator speed.</p>
</html>"));
      end GMS;

      model GMSoo "Genset Management System (simplified)"
        parameter Real tauMax = 100 "maximum torque internally exchanged by the two machines";
        parameter Real throttlePerWerr = 0.01 "speed controller gain (throttle per rad/s)";
        parameter Boolean tablesOnFile = false;
        parameter String mapsFileName = "maps.txt" "Name of the file containing data maps (names: maxIceTau, specificCons, optiSpeed)" annotation (
          Dialog(enable = tablesOnFile));
        parameter Real optiTable[:, :] = [0, 800; 20000, 850; 40000, 1100; 60000, 1250; 80000, 1280; 100000, 1340; 120000, 1400; 140000, 1650; 160000, 2130] "first row: speed, 1st column: torque, body: sp. consumption" annotation (
          Dialog(enable = not tablesOnFile));
        import Modelica.Constants.pi;
        Modelica.Blocks.Tables.CombiTable1D optiSpeed(columns = {2}, smoothness = Modelica.Blocks.Types.Smoothness.ContinuousDerivative, table = optiTable, fileName = mapsFileName, tableOnFile = tablesOnFile, tableName = "optiSpeed") "gives the optimal spees ad a function of requested power" annotation (
          Placement(visible = true, transformation(extent = {{-66, -22}, {-46, -2}}, rotation = 0)));
        Modelica.Blocks.Math.Division division annotation (
          Placement(visible = true, transformation(origin = {4, 16}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Interfaces.RealInput Wmecc annotation (
          Placement(visible = true, transformation(origin = {0, -96}, extent = {{-20, -20}, {20, 20}}, rotation = 90), iconTransformation(origin = {1, -115}, extent = {{-15, -15}, {15, 15}}, rotation = 90)));
        Modelica.Blocks.Interfaces.RealInput pRef annotation (
          Placement(visible = true, transformation(extent = {{-140, -60}, {-100, -20}}, rotation = 0), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput tRef "Torque request (positive when ICE delivers power)" annotation (
          Placement(visible = true, transformation(extent = {{100, 30}, {120, 50}}, rotation = 0), iconTransformation(extent = {{100, 50}, {120, 70}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput throttle annotation (
          Placement(visible = true, transformation(extent = {{100, -50}, {120, -30}}, rotation = 0), iconTransformation(extent = {{100, -70}, {120, -50}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{24, -30}, {44, -10}}, rotation = 0)));
        Modelica.Blocks.Math.Gain gain(k = throttlePerWerr) annotation (
          Placement(visible = true, transformation(extent = {{66, -30}, {86, -10}}, rotation = 0)));
        Modelica.Blocks.Math.UnitConversions.To_rpm to_rpm annotation (
          Placement(visible = true, transformation(origin = {34, -50}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Interfaces.BooleanInput on annotation (
          Placement(visible = true, transformation(extent = {{-138, 28}, {-98, 68}}, rotation = 0), iconTransformation(extent = {{-138, 40}, {-98, 80}}, rotation = 0)));
        Modelica.Blocks.Logical.Switch switch1 annotation (
          Placement(visible = true, transformation(extent = {{-18, -30}, {2, -10}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant zero(k = 0) annotation (
          Placement(visible = true, transformation(extent = {{-60, -60}, {-40, -40}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limMinW(uMax = 1e9, uMin = 10) annotation (
          Placement(visible = true, transformation(origin = {4, -48}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Tables.CombiTable1D maxTau(tableOnFile = true, columns = {2}, fileName = mapsFileName, tableName = "maxIceTau") "gives the optimal spees ad a function of requested power" annotation (
          Placement(transformation(extent = {{14, 38}, {34, 58}})));
        Modelica.Blocks.Math.Gain gain1(k = -1) annotation (
          Placement(transformation(extent = {{34, 4}, {50, 20}})));
        Modelica.Blocks.Nonlinear.VariableLimiter tauLimiter annotation (
          Placement(transformation(extent = {{62, 26}, {82, 46}})));
        Modelica.Blocks.Sources.RealExpression realExpression(y = Wmecc) annotation (
          Placement(transformation(extent = {{-24, 36}, {-4, 56}})));
      equation
        connect(to_rpm.u, Wmecc) annotation (
          Line(points = {{34, -62}, {34, -70}, {0, -70}, {0, -96}}, color = {0, 0, 127}));
        connect(zero.y, switch1.u3) annotation (
          Line(points = {{-39, -50}, {-30, -50}, {-30, -28}, {-20, -28}}, color = {0, 0, 127}));
        connect(on, switch1.u2) annotation (
          Line(points = {{-118, 48}, {-34, 48}, {-34, -20}, {-20, -20}}, color = {255, 0, 255}));
        connect(optiSpeed.y[1], switch1.u1) annotation (
          Line(points = {{-45, -12}, {-45, -12}, {-20, -12}}, color = {0, 0, 127}));
        connect(switch1.y, feedback.u1) annotation (
          Line(points = {{3, -20}, {26, -20}}, color = {0, 0, 127}));
        connect(to_rpm.y, feedback.u2) annotation (
          Line(points = {{34, -39}, {34, -39}, {34, -28}}, color = {0, 0, 127}));
        connect(feedback.y, gain.u) annotation (
          Line(points = {{43, -20}, {64, -20}}, color = {0, 0, 127}));
        connect(throttle, gain.y) annotation (
          Line(points = {{110, -40}, {98, -40}, {98, -20}, {87, -20}}, color = {0, 0, 127}));
        connect(division.u1, optiSpeed.u[1]) annotation (
          Line(points = {{-2, 4}, {-80, 4}, {-80, -12}, {-68, -12}}, color = {0, 0, 127}));
        connect(optiSpeed.u[1], pRef) annotation (
          Line(points = {{-68, -12}, {-80, -12}, {-80, -40}, {-120, -40}}, color = {0, 0, 127}));
        connect(limMinW.u, Wmecc) annotation (
          Line(points = {{4, -60}, {4, -70}, {0, -70}, {0, -96}}, color = {0, 0, 127}));
        connect(limMinW.y, division.u2) annotation (
          Line(points = {{4, -37}, {6, -37}, {6, 4}, {10, 4}}, color = {0, 0, 127}));
        connect(tauLimiter.y, tRef) annotation (
          Line(points = {{83, 36}, {96, 36}, {96, 40}, {110, 40}}, color = {0, 0, 127}));
        connect(maxTau.y[1], tauLimiter.limit1) annotation (
          Line(points = {{35, 48}, {60, 48}, {60, 44}}, color = {0, 0, 127}));
        connect(tauLimiter.limit2, gain1.y) annotation (
          Line(points = {{60, 28}, {58, 28}, {58, 26}, {50.8, 26}, {50.8, 12}}, color = {0, 0, 127}));
        connect(gain1.u, tauLimiter.limit1) annotation (
          Line(points = {{32.4, 12}, {26, 12}, {26, 30}, {44, 30}, {44, 48}, {60, 48}, {60, 44}}, color = {0, 0, 127}));
        connect(division.y, tauLimiter.u) annotation (
          Line(points = {{4, 27}, {4, 36}, {60, 36}}, color = {0, 0, 127}));
        connect(realExpression.y, maxTau.u[1]) annotation (
          Line(points = {{-3, 46}, {4, 46}, {4, 48}, {12, 48}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 60}})),
          experiment(StopTime = 3, Interval = 0.01),
          experimentSetupOutput,
          Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Text(origin = {-2, 0}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-98, 22}, {98, -16}}, textString = "%name")}),
          Documentation(info = "<html>
<p>Genset Management System witn ON/OFF.</p>
<p>The control logic commands the genset to deliver at the DC port the input power, using the optimal generator speed.</p>
<p>In addition, it commands ON or OFF depending on the input boolean control signal.</p>
</html>"),__OpenModelica_commandLineOptions = "");
      end GMSoo;

      block EleBalanceTau
        parameter Real sigma;
        Modelica.Blocks.Interfaces.RealInput motW annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {-60, 116})));
        Modelica.Blocks.Interfaces.RealInput iceW annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {60, 114})));
        Modelica.Blocks.Interfaces.RealOutput tauMot annotation (
          Placement(transformation(extent = {{98, -10}, {118, 10}})));
        Modelica.Blocks.Interfaces.RealInput tauP annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = -90, origin = {0, 116})));
      equation
        tauMot = tauP * ((1 + sigma) * iceW - motW) / ((1 + sigma) * iceW);
        annotation (
          Icon(coordinateSystem(preserveAspectRatio = false)),
          Diagram(coordinateSystem(preserveAspectRatio = false)));
      end EleBalanceTau;

      model EMS "Ice, Generator, DriveTrain, all map-based"
        //€
        parameter Real tauPowFilt = 300 "power filter time constant";
        parameter Real powLow = 3000 "hysteresis control lower limit";
        parameter Real powHigh = 5000 "hysteresis control higher limit";
        parameter Real powPerSoc = 100e3 "SOC loop gain";
        parameter Real powMax = 100e3 "Max power that can be requested as output";
        parameter Real socRef = 0.7;
        Modelica.Blocks.Nonlinear.Limiter limiter(uMin = 0, uMax = powMax) annotation (
          Placement(visible = true, transformation(origin = {12, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Math.Feedback fbSOC annotation (
          Placement(visible = true, transformation(origin = {-60, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant socRef_(k = socRef) annotation (
          Placement(visible = true, transformation(origin = {-90, 0}, extent = {{10, 10}, {-10, -10}}, rotation = 180)));
        Modelica.Blocks.Math.Gain socErrToPow(k = powPerSoc) annotation (
          Placement(visible = true, transformation(origin = {-40, 22}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
        Modelica.Blocks.Math.Add add annotation (
          Placement(visible = true, transformation(origin = {-18, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealInput edPow annotation (
          Placement(visible = true, transformation(origin = {-120, 40}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-120, 60}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealInput soc annotation (
          Placement(visible = true, transformation(origin = {-120, -40}, extent = {{-20, -20}, {20, 20}}, rotation = 0), iconTransformation(origin = {-120, -60}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
        Modelica.Blocks.Logical.Switch powSwitch annotation (
          Placement(visible = true, transformation(origin = {64, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Logical.Hysteresis powHyst(uHigh = powHigh, uLow = powLow) annotation (
          Placement(visible = true, transformation(origin = {50, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant zero(k = 0.0) annotation (
          Placement(visible = true, transformation(origin = {26, -48}, extent = {{10, 10}, {-10, -10}}, rotation = 180)));
        Modelica.Blocks.Interfaces.BooleanOutput on annotation (
          Placement(visible = true, transformation(extent = {{100, 30}, {120, 50}}, rotation = 0), iconTransformation(extent = {{98, 50}, {118, 70}}, rotation = 0)));
        Modelica.Blocks.Interfaces.RealOutput pcPowReq(displayUnit = "kW") annotation (
          Placement(visible = true, transformation(extent = {{100, -50}, {120, -30}}, rotation = 0), iconTransformation(extent = {{98, -70}, {118, -50}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder powFilt(y_start = 20e3, T = tauPowFilt) annotation (
          Placement(transformation(extent = {{-72, 44}, {-56, 60}})));
      equation
        connect(powSwitch.u1, limiter.y) annotation (
          Line(points = {{52, -12}, {30, -12}, {30, 46}, {23, 46}}, color = {0, 0, 127}));
        connect(powSwitch.u3, zero.y) annotation (
          Line(points = {{52, -28}, {44, -28}, {44, -48}, {37, -48}}, color = {0, 0, 127}));
        connect(powHyst.u, limiter.y) annotation (
          Line(points = {{38, 46}, {23, 46}}, color = {0, 0, 127}));
        connect(socErrToPow.y, add.u2) annotation (
          Line(points = {{-40, 33}, {-40, 40}, {-30, 40}}, color = {0, 0, 127}));
        connect(limiter.u, add.y) annotation (
          Line(points = {{0, 46}, {0, 46}, {-7, 46}}, color = {0, 0, 127}));
        connect(socErrToPow.u, fbSOC.y) annotation (
          Line(points = {{-40, 10}, {-40, 0}, {-51, 0}}, color = {0, 0, 127}));
        connect(fbSOC.u2, soc) annotation (
          Line(points = {{-60, -8}, {-60, -40}, {-120, -40}}, color = {0, 0, 127}));
        connect(socRef_.y, fbSOC.u1) annotation (
          Line(points = {{-79, -1.33227e-015}, {-76, -1.33227e-015}, {-76, 0}, {-74, 0}, {-68, 0}}, color = {0, 0, 127}));
        connect(powSwitch.u2, on) annotation (
          Line(points = {{52, -20}, {40, -20}, {26, -20}, {26, 22}, {88, 22}, {88, 40}, {110, 40}}, color = {255, 0, 255}));
        connect(powSwitch.y, pcPowReq) annotation (
          Line(points = {{75, -20}, {84, -20}, {84, -40}, {110, -40}}, color = {0, 0, 127}));
        connect(powFilt.y, add.u1) annotation (
          Line(points = {{-55.2, 52}, {-44, 52}, {-30, 52}}, color = {0, 0, 127}));
        connect(powFilt.u, edPow) annotation (
          Line(points = {{-73.6, 52}, {-78, 52}, {-78, 40}, {-120, 40}}, color = {0, 0, 127}));
        connect(powHyst.y, on) annotation (
          Line(points = {{61, 46}, {88, 46}, {88, 40}, {110, 40}}, color = {255, 0, 255}));
        annotation (
          Placement(visible = true, transformation(origin = {-58, 50}, extent = {{-10, -10}, {10, 10}}, rotation = 0)),
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(initialScale = 0.1), graphics = {Rectangle(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Polygon(lineColor = {95, 95, 95}, fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid, points = {{-4, -40}, {74, 16}, {74, -6}, {-4, -62}, {-4, -40}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{8, -38}, {28, -48}, {20, -54}, {0, -44}, {8, -38}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{20, -54}, {28, -48}, {32, -56}, {24, -62}, {20, -54}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{24, -62}, {32, -56}, {32, -78}, {24, -84}, {24, -62}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{0, -44}, {20, -54}, {24, -62}, {24, -84}, {22, -84}, {22, -62}, {20, -58}, {0, -48}, {0, -44}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-14, 40}, {-18, 32}, {-10, 38}, {-8, 44}, {-14, 40}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-18, 32}, {-10, 38}, {-10, 14}, {-18, 8}, {-18, 32}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-20, 10}, {-20, 32}, {-16, 40}, {4, 30}, {4, 26}, {-16, 36}, {-18, 32}, {-18, 8}, {-20, 10}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-8, 46}, {12, 36}, {4, 30}, {-16, 40}, {-8, 46}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{28, -22}, {48, -32}, {40, -38}, {20, -28}, {28, -22}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{40, -38}, {48, -32}, {52, -40}, {44, -46}, {40, -38}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{44, -46}, {52, -40}, {52, -62}, {44, -68}, {44, -46}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{20, -28}, {40, -38}, {44, -46}, {44, -68}, {42, -68}, {42, -46}, {40, -42}, {20, -32}, {20, -28}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{48, -8}, {68, -18}, {60, -24}, {40, -14}, {48, -8}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{60, -24}, {68, -18}, {72, -26}, {64, -32}, {60, -24}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{64, -32}, {72, -26}, {72, -48}, {64, -54}, {64, -32}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{40, -14}, {60, -24}, {64, -32}, {64, -54}, {62, -54}, {62, -32}, {60, -28}, {40, -18}, {40, -14}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{68, 6}, {88, -4}, {80, -10}, {60, 0}, {68, 6}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{80, -10}, {88, -4}, {92, -12}, {84, -18}, {80, -10}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{84, -18}, {92, -12}, {92, -34}, {84, -40}, {84, -18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{60, 0}, {80, -10}, {84, -18}, {84, -40}, {82, -40}, {82, -18}, {80, -14}, {60, -4}, {60, 0}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-34, 26}, {-38, 18}, {-30, 24}, {-28, 30}, {-34, 26}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-38, 18}, {-30, 24}, {-30, 0}, {-38, -6}, {-38, 18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-40, -4}, {-40, 18}, {-36, 26}, {-16, 16}, {-16, 12}, {-36, 22}, {-38, 18}, {-38, -6}, {-40, -4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-28, 32}, {-8, 22}, {-16, 16}, {-36, 26}, {-28, 32}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-54, 12}, {-58, 4}, {-50, 10}, {-48, 16}, {-54, 12}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-58, 4}, {-50, 10}, {-50, -14}, {-58, -20}, {-58, 4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-60, -18}, {-60, 4}, {-56, 12}, {-36, 2}, {-36, -2}, {-56, 8}, {-58, 4}, {-58, -20}, {-60, -18}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-48, 18}, {-28, 8}, {-36, 2}, {-56, 12}, {-48, 18}}), Polygon(lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid, points = {{-74, -4}, {-78, -12}, {-70, -6}, {-68, 0}, {-74, -4}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid, points = {{-78, -12}, {-70, -6}, {-70, -30}, {-78, -36}, {-78, -12}}), Polygon(lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid, points = {{-80, -34}, {-80, -12}, {-76, -4}, {-56, -14}, {-56, -18}, {-76, -8}, {-78, -12}, {-78, -36}, {-80, -34}}), Polygon(lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid, points = {{-68, 2}, {-48, -8}, {-56, -14}, {-76, -4}, {-68, 2}}), Polygon(lineColor = {95, 95, 95}, fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid, points = {{-64, -8}, {-4, -40}, {-4, -62}, {-64, -30}, {-64, -8}}), Polygon(lineColor = {95, 95, 95}, fillColor = {160, 160, 164}, fillPattern = FillPattern.Solid, points = {{-64, -8}, {-4, -40}, {74, 16}, {14, 48}, {-64, -8}}), Rectangle(fillColor = {255, 255, 255}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, extent = {{-98, 92}, {98, 62}}), Text(origin = {-6.08518, -4.3529}, lineColor = {0, 0, 255}, extent = {{-91.9148, 98.3529}, {100.085, 60.353}}, textString = "%name", fontName = "Helvetica")}),
          experiment(StopTime = 1800, __Dymola_NumberOfIntervals = 2000),
          experimentSetupOutput(derivatives = false),
          Documentation(info = "<html>
<p>SHEV logic. Contains:</p>
<p>- basic logic, which requests the average load power from the ICE</p>
<p>- additional SOC loop to avoid SOC drift</p>
<p>- further ON/OFF control to switch OFF the engine when the average power is too low to permit efficient operation</p>
</html>"),__OpenModelica_commandLineOptions = "");
      end EMS;
    end ECUs;
    annotation (
      Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics={  Line(points = {{-80, -84}, {-80, 68}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-88, -80}, {78, -80}}, color = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{94, -80}, {78, -74}, {78, -86}, {94, -80}}, lineColor = {0, 0, 0}, smooth = Smooth.None), Polygon(points = {{8, 0}, {-8, 6}, {-8, -6}, {8, 0}}, lineColor = {0, 0, 0}, smooth = Smooth.None, origin = {-80, 76}, rotation = 90), Line(points = {{-84, 40}, {-14, 40}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{-14, 40}, {-4, 2}, {22, -32}, {62, -44}, {62, -80}}, color = {0, 0, 0}, smooth = Smooth.None)}));
  end MapBased;

  package Icons
    model EcuIcon
      SupportModels.ConnectorRelated.Conn conn1 annotation (
        Placement(visible = true, transformation(extent = {{-20, 78}, {20, 118}}, rotation = 0), iconTransformation(extent = {{-20, 80}, {20, 120}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealInput motTauInt annotation (
        Placement(visible = true, transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
      annotation (
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Polygon(points = {{-4, -40}, {74, 16}, {74, -6}, {-4, -62}, {-4, -40}}, lineColor = {95, 95, 95}, fillColor = {175, 175, 175}, fillPattern = FillPattern.Solid), Polygon(points = {{8, -38}, {28, -48}, {20, -54}, {0, -44}, {8, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -54}, {28, -48}, {32, -56}, {24, -62}, {20, -54}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{24, -62}, {32, -56}, {32, -78}, {24, -84}, {24, -62}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{0, -44}, {20, -54}, {24, -62}, {24, -84}, {22, -84}, {22, -62}, {20, -58}, {0, -48}, {0, -44}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-14, 40}, {-18, 32}, {-10, 38}, {-8, 44}, {-14, 40}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-18, 32}, {-10, 38}, {-10, 14}, {-18, 8}, {-18, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-20, 10}, {-20, 32}, {-16, 40}, {4, 30}, {4, 26}, {-16, 36}, {-18, 32}, {-18, 8}, {-20, 10}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-8, 46}, {12, 36}, {4, 30}, {-16, 40}, {-8, 46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{28, -22}, {48, -32}, {40, -38}, {20, -28}, {28, -22}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -38}, {48, -32}, {52, -40}, {44, -46}, {40, -38}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{44, -46}, {52, -40}, {52, -62}, {44, -68}, {44, -46}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{20, -28}, {40, -38}, {44, -46}, {44, -68}, {42, -68}, {42, -46}, {40, -42}, {20, -32}, {20, -28}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{48, -8}, {68, -18}, {60, -24}, {40, -14}, {48, -8}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{60, -24}, {68, -18}, {72, -26}, {64, -32}, {60, -24}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{64, -32}, {72, -26}, {72, -48}, {64, -54}, {64, -32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{40, -14}, {60, -24}, {64, -32}, {64, -54}, {62, -54}, {62, -32}, {60, -28}, {40, -18}, {40, -14}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{68, 6}, {88, -4}, {80, -10}, {60, 0}, {68, 6}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{80, -10}, {88, -4}, {92, -12}, {84, -18}, {80, -10}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{84, -18}, {92, -12}, {92, -34}, {84, -40}, {84, -18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{60, 0}, {80, -10}, {84, -18}, {84, -40}, {82, -40}, {82, -18}, {80, -14}, {60, -4}, {60, 0}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-34, 26}, {-38, 18}, {-30, 24}, {-28, 30}, {-34, 26}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-38, 18}, {-30, 24}, {-30, 0}, {-38, -6}, {-38, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-40, -4}, {-40, 18}, {-36, 26}, {-16, 16}, {-16, 12}, {-36, 22}, {-38, 18}, {-38, -6}, {-40, -4}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-28, 32}, {-8, 22}, {-16, 16}, {-36, 26}, {-28, 32}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-54, 12}, {-58, 4}, {-50, 10}, {-48, 16}, {-54, 12}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-58, 4}, {-50, 10}, {-50, -14}, {-58, -20}, {-58, 4}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-60, -18}, {-60, 4}, {-56, 12}, {-36, 2}, {-36, -2}, {-56, 8}, {-58, 4}, {-58, -20}, {-60, -18}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-48, 18}, {-28, 8}, {-36, 2}, {-56, 12}, {-48, 18}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-74, -4}, {-78, -12}, {-70, -6}, {-68, 0}, {-74, -4}}, lineColor = {128, 128, 128}, fillColor = {128, 128, 128}, fillPattern = FillPattern.Solid), Polygon(points = {{-78, -12}, {-70, -6}, {-70, -30}, {-78, -36}, {-78, -12}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 127}, fillPattern = FillPattern.Solid), Polygon(points = {{-80, -34}, {-80, -12}, {-76, -4}, {-56, -14}, {-56, -18}, {-76, -8}, {-78, -12}, {-78, -36}, {-80, -34}}, lineColor = {0, 0, 255}, fillColor = {191, 191, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-68, 2}, {-48, -8}, {-56, -14}, {-76, -4}, {-68, 2}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 0}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {-4, -62}, {-64, -30}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {75, 75, 75}, fillPattern = FillPattern.Solid), Polygon(points = {{-64, -8}, {-4, -40}, {74, 16}, {14, 48}, {-64, -8}}, lineColor = {95, 95, 95}, fillColor = {160, 160, 164}, fillPattern = FillPattern.Solid), Text(origin = {-1, -42}, lineColor = {0, 0, 255}, extent = {{-119, -64}, {119, -104}}, textString = "%name"), Rectangle(extent = {{-98, 92}, {98, 62}}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, pattern = LinePattern.None)}),
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics));
    end EcuIcon;

    model SupportIcon
      annotation (
        Icon(graphics = {Ellipse(extent = {{-38, 38}, {38, -38}}, lineColor = {0, 0, 0}), Line(points = {{2, 80}, {-8, 80}, {-12, 70}, {-26, 66}, {-36, 76}, {-48, 68}, {-44, 56}, {-56, 44}, {-68, 48}, {-76, 34}, {-68, 28}, {-70, 14}, {-80, 10}, {-80, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{2, -80}, {-8, -80}, {-12, -70}, {-26, -66}, {-36, -76}, {-48, -68}, {-44, -56}, {-56, -44}, {-68, -48}, {-76, -34}, {-68, -28}, {-70, -14}, {-80, -10}, {-80, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{0, -80}, {10, -80}, {14, -70}, {28, -66}, {38, -76}, {50, -68}, {46, -56}, {58, -44}, {70, -48}, {78, -34}, {70, -28}, {72, -14}, {82, -10}, {82, 0}}, color = {0, 0, 0}, smooth = Smooth.None), Line(points = {{0, 80}, {10, 80}, {14, 70}, {28, 66}, {38, 76}, {50, 68}, {46, 56}, {58, 44}, {70, 48}, {78, 34}, {70, 28}, {72, 14}, {82, 10}, {82, 0}}, color = {0, 0, 0}, smooth = Smooth.None)}));
    end SupportIcon;
  end Icons;

  package ElectricDrives
    package TestingModels
      extends Modelica.Icons.ExamplesPackage;

      model StartASMA "Compares U/f=cost and mains start-ups"
        //
        import Modelica.Constants.pi;
        Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox(terminalConnection = "Y") annotation (
          Placement(visible = true, transformation(extent = {{4, 38}, {24, 58}}, rotation = 0)));
        Modelica.Electrical.Machines.BasicMachines.AsynchronousInductionMachines.AIM_SquirrelCage aimc annotation (
          Placement(visible = true, transformation(extent = {{4, 8}, {24, 28}}, rotation = 0)));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(visible = true, transformation(extent = {{-112, -6}, {-92, 14}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Basic.Star star annotation (
          Placement(visible = true, transformation(origin = {-102, 38}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Mechanics.Rotational.Sources.Torque torque annotation (
          Placement(visible = true, transformation(origin = {78, 18}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Blocks.Sources.Constant tauLoad(k = -150) annotation (
          Placement(visible = true, transformation(origin = {111, -11}, extent = {{-9, -9}, {9, 9}}, rotation = 180)));
        SupportModels.Miscellaneous.AronSensor pUp annotation (
          Placement(visible = true, transformation(extent = {{-52, 44}, {-34, 62}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sources.SignalVoltage signalV annotation (
          Placement(visible = true, transformation(origin = {-72, 53}, extent = {{-10, -9}, {10, 9}}, rotation = 180)));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
          Placement(visible = true, transformation(origin = {61, -1}, extent = {{-7, -7}, {7, 7}}, rotation = 270)));
        Modelica.Mechanics.Rotational.Sources.Torque torque1 annotation (
          Placement(visible = true, transformation(origin = {76, -56}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox1(terminalConnection = "Y") annotation (
          Placement(visible = true, transformation(extent = {{10, -36}, {30, -16}}, rotation = 0)));
        Modelica.Electrical.Machines.BasicMachines.AsynchronousInductionMachines.AIM_SquirrelCage aimc0 annotation (
          Placement(visible = true, transformation(extent = {{10, -66}, {30, -46}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sensors.CurrentSensor Idown annotation (
          Placement(visible = true, transformation(origin = {-6, -30}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Electrical.Analog.Basic.Ground ground2 annotation (
          Placement(visible = true, transformation(extent = {{-118, -78}, {-98, -58}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Basic.Star star2 annotation (
          Placement(visible = true, transformation(origin = {-98, -34}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
        Modelica.Electrical.MultiPhase.Sources.SineVoltage sineVoltage(freqHz = 50 * ones(3), V = 100 * sqrt(2) * ones(3)) annotation (
          Placement(visible = true, transformation(extent = {{-78, -44}, {-58, -24}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sensors.CurrentSensor iUp annotation (
          Placement(visible = true, transformation(origin = {-14, 54}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        SupportModels.Miscellaneous.AronSensor pDown annotation (
          Placement(visible = true, transformation(extent = {{-48, -44}, {-30, -26}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5) annotation (
          Placement(visible = true, transformation(extent = {{34, 8}, {54, 28}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia inertia0(J = 0.5) annotation (
          Placement(visible = true, transformation(extent = {{38, -66}, {58, -46}}, rotation = 0)));
        ASMArelated.ControlLogic logic(Lstray = 0.2036 / 314.16, Rr = aimc.Rr, Rs = aimc.Rs, uBase = 100 * sqrt(3), pp = 2, wmMax = 314.16 / 2) annotation (
          Placement(visible = true, transformation(extent = {{-32, 0}, {-52, 20}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant const1(k = 220) annotation (
          Placement(visible = true, transformation(origin = {-14, 10}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
        ASMArelated.GenSines actuator annotation (
          Placement(visible = true, transformation(extent = {{-62, 0}, {-84, 20}}, rotation = 0)));
      equation
        connect(tauLoad.y, torque1.tau) annotation (
          Line(points = {{101.1, -11}, {98, -11}, {98, -24}, {94, -24}, {94, -56}, {88, -56}}, color = {0, 0, 127}));
        connect(tauLoad.y, torque.tau) annotation (
          Line(points = {{101.1, -11}, {98, -11}, {98, 18}, {90, 18}}, color = {0, 0, 127}));
        connect(torque1.flange, inertia0.flange_b) annotation (
          Line(points = {{66, -56}, {66, -56}, {58, -56}}));
        connect(aimc0.flange, inertia0.flange_a) annotation (
          Line(points = {{30, -56}, {38, -56}}));
        connect(Idown.plug_n, terminalBox1.plugSupply) annotation (
          Line(points = {{2, -30}, {20, -30}}, color = {0, 0, 255}));
        connect(terminalBox1.plug_sn, aimc0.plug_sn) annotation (
          Line(points = {{14, -32}, {14, -46}}, color = {0, 0, 255}));
        connect(terminalBox1.plug_sp, aimc0.plug_sp) annotation (
          Line(points = {{26, -32}, {26, -46}}, color = {0, 0, 255}));
        connect(pDown.nc, Idown.plug_p) annotation (
          Line(points = {{-30, -35}, {-14, -35}, {-14, -30}}, color = {0, 0, 255}));
        connect(pDown.pc, sineVoltage.plug_n) annotation (
          Line(points = {{-48, -35}, {-48.09, -35}, {-48.09, -34}, {-58, -34}}, color = {0, 0, 255}));
        connect(sineVoltage.plug_p, star2.plug_p) annotation (
          Line(points = {{-78, -34}, {-88, -34}}, color = {0, 0, 255}));
        connect(ground2.p, star2.pin_n) annotation (
          Line(points = {{-108, -58}, {-108, -34}}, color = {0, 0, 255}));
        connect(inertia.flange_b, torque.flange) annotation (
          Line(points = {{54, 18}, {62, 18}, {68, 18}}));
        connect(speedSensor.flange, torque.flange) annotation (
          Line(points = {{61, 6}, {61, 12}, {60, 12}, {60, 18}, {68, 18}}));
        connect(logic.Wm, speedSensor.w) annotation (
          Line(points = {{-42.1, -1.3}, {-42.1, -14}, {61, -14}, {61, -8.7}}, color = {0, 0, 127}));
        connect(inertia.flange_a, aimc.flange) annotation (
          Line(points = {{34, 18}, {24, 18}}));
        connect(iUp.plug_n, terminalBox.plugSupply) annotation (
          Line(points = {{-6, 54}, {-6, 54}, {14, 54}, {14, 44}}, color = {0, 0, 255}));
        connect(terminalBox.plug_sp, aimc.plug_sp) annotation (
          Line(points = {{20, 42}, {20, 28}}, color = {0, 0, 255}));
        connect(terminalBox.plug_sn, aimc.plug_sn) annotation (
          Line(points = {{8, 42}, {8, 28}}, color = {0, 0, 255}));
        connect(ground.p, star.pin_n) annotation (
          Line(points = {{-102, 14}, {-102, 28}}, color = {0, 0, 255}));
        connect(iUp.plug_p, pUp.nc) annotation (
          Line(points = {{-22, 54}, {-34, 54}, {-34, 53}}, color = {0, 0, 255}));
        connect(logic.Tstar, const1.y) annotation (
          Line(points = {{-30.1, 9.9}, {-28, 9.9}, {-28, 10}, {-25, 10}}, color = {0, 0, 127}));
        connect(actuator.Ustar, logic.Ustar) annotation (
          Line(points = {{-60.57, 4.1}, {-62.25, 4.1}, {-62.25, 4}, {-53, 4}}, color = {0, 0, 127}));
        connect(actuator.Westar, logic.Westar) annotation (
          Line(points = {{-60.57, 15.9}, {-61.35, 15.9}, {-61.35, 16}, {-53, 16}}, color = {0, 0, 127}));
        connect(actuator.U, signalV.v) annotation (
          Line(points = {{-85.1, 10}, {-88, 10}, {-88, 12}, {-88, 40}, {-72, 40}, {-72, 42.2}}, color = {0, 0, 127}));
        connect(pUp.pc, signalV.plug_p) annotation (
          Line(points = {{-52, 53}, {-62, 53}}, color = {0, 0, 255}));
        connect(signalV.plug_n, star.plug_p) annotation (
          Line(points = {{-82, 53}, {-102, 53}, {-102, 48}}, color = {0, 0, 255}));
        annotation (
          experimentSetupOutput,
          Documentation(info = "<html>
<p>This system simulates variable-frequency start-up of an asyncronous motor.</p>
<p>Two different sources for the machine are compared.</p>
<p>The motor supply is constituted by a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</p>
<p>WEl=WMecc*PolePairs+DeltaWEl</p>
<p>U=U0+(Un-U0)*WEl/WNom</p>
<p>where:</p>
<ul>
<li>U0, Un U, are initial, nominal actual voltage amplitudes</li>
<li>WMecc, WEl, are machine, mechanical and supply, electrical angular speeds</li>
<li>PolePairs are the machine pole pairs</li>
<li>delta WEl is a fixed parameter during the simulation, except when the final speed is reached</li>
</ul>
<p>When the final speed is reached, the feeding frequenccy and voltage are kept constant (no flux weaking simulated)</p>
</html>"),experimentSetupOutput,
          Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}})),
          Diagram(coordinateSystem(extent = {{-120, -80}, {120, 80}}, preserveAspectRatio = false, initialScale = 0.1)),
          experiment(StartTime = 0, StopTime = 3, Tolerance = 0.0001, Interval = 0.0006));
      end StartASMA;

      model SmaDriveFW "Synchrnous Machine electric drive with flux weakening"
        //  extends Modelica.Icons.Example;
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.29, phi(fixed = true, start = 0), w(fixed = true, start = 0)) annotation (
          Placement(transformation(extent = {{72, -20}, {92, 0}})));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(transformation(extent = {{88, 28}, {108, 48}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque tRes(w_nominal(displayUnit = "rpm") = 157.07963267949, tau_nominal = -100) annotation (
          Placement(transformation(extent = {{118, -20}, {98, 0}})));
        Modelica.Electrical.Machines.BasicMachines.SynchronousInductionMachines.SM_PermanentMagnet smpm(useDamperCage = false) annotation (
          Placement(transformation(extent = {{30, -20}, {50, 0}}, rotation = 0)));
        Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox1(terminalConnection = "Y") annotation (
          Placement(transformation(extent = {{30, 8}, {50, 28}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sources.SignalCurrent signalCurr1(final m = 3) annotation (
          Placement(transformation(origin = {40, 42}, extent = {{-10, 10}, {10, -10}}, rotation = 270)));
        Modelica.Electrical.MultiPhase.Basic.Star star1(final m = 3) annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 180, origin = {72, 52})));
        Modelica.Blocks.Sources.Constant uDC(k = 200) annotation (
          Placement(transformation(extent = {{-96, 32}, {-76, 52}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wMeccSens annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {62, -24})));
        Modelica.Blocks.Continuous.Integrator integrator annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = -90, origin = {-10, -6})));
        ElectricDrives.SMArelated.FromPark fromPark(p = smpm.p) annotation (
          Placement(transformation(extent = {{-20, 32}, {0, 52}})));
        Modelica.Electrical.Analog.Basic.Ground groundM1 annotation (
          Placement(transformation(origin = {14, 14}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        ElectricDrives.SMArelated.MTPAi myMTPA(Umax = 100, Ipm = smpm.permanentMagnet.Ie, pp = smpm.p, Rs = smpm.Rs, Ld = smpm.Lmd) annotation (
          Placement(visible = true, transformation(extent = {{-48, 32}, {-28, 52}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder firstOrder1[3](T = 0.2e-4 * {1, 1, 1}) annotation (
          Placement(visible = true, transformation(origin = {18, 42}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Blocks.Sources.Ramp tqRef(height = 100, duration = 1) annotation (
          Placement(transformation(extent = {{-96, -38}, {-76, -18}})));
      equation
        connect(myMTPA.wMech, integrator.u) annotation (
          Line(points = {{-50, 36}, {-58, 36}, {-58, -28}, {-10, -28}, {-10, -18}}, color = {0, 0, 127}));
        connect(fromPark.Xq, myMTPA.Iq) annotation (
          Line(points = {{-22, 36}, {-24, 36}, {-24, 36}, {-27, 36}}, color = {0, 0, 127}));
        connect(fromPark.Xd, myMTPA.Id) annotation (
          Line(points = {{-22, 48}, {-27, 48}}, color = {0, 0, 127}));
        connect(myMTPA.uDC, uDC.y) annotation (
          Line(points = {{-50, 42}, {-75, 42}}, color = {0, 0, 127}));
        connect(inertia.flange_b, tRes.flange) annotation (
          Line(points = {{92, -10}, {98, -10}}, color = {0, 0, 0}, smooth = Smooth.None));
        connect(terminalBox1.plug_sn, smpm.plug_sn) annotation (
          Line(points = {{34, 12}, {34, 0}}, color = {0, 0, 255}));
        connect(terminalBox1.plug_sp, smpm.plug_sp) annotation (
          Line(points = {{46, 12}, {46, 0}}, color = {0, 0, 255}));
        connect(star1.plug_p, signalCurr1.plug_p) annotation (
          Line(points = {{62, 52}, {40, 52}}, color = {0, 0, 255}));
        connect(star1.pin_n, ground.p) annotation (
          Line(points = {{82, 52}, {98, 52}, {98, 48}}, color = {0, 0, 255}));
        connect(inertia.flange_a, smpm.flange) annotation (
          Line(points = {{72, -10}, {50, -10}}, color = {0, 0, 0}));
        connect(signalCurr1.plug_n, terminalBox1.plugSupply) annotation (
          Line(points = {{40, 32}, {40, 14}}, color = {0, 0, 255}));
        connect(wMeccSens.flange, smpm.flange) annotation (
          Line(points = {{62, -14}, {62, -10}, {50, -10}}, color = {0, 0, 0}));
        connect(wMeccSens.w, integrator.u) annotation (
          Line(points = {{62, -35}, {62, -40}, {12, -40}, {12, -28}, {-10, -28}, {-10, -18}}, color = {0, 0, 127}));
        connect(integrator.y, fromPark.phi) annotation (
          Line(points = {{-10, 5}, {-10, 30}}, color = {0, 0, 127}));
        connect(groundM1.p, terminalBox1.starpoint) annotation (
          Line(points = {{24, 14}, {30, 14}}, color = {0, 0, 255}));
        connect(firstOrder1.u, fromPark.y) annotation (
          Line(points = {{8.4, 42}, {1, 42}}, color = {0, 0, 127}));
        connect(firstOrder1.y, signalCurr1.i) annotation (
          Line(points = {{26.8, 42}, {28, 42}}, color = {0, 0, 127}));
        connect(tqRef.y, myMTPA.torqueReq) annotation (
          Line(points = {{-75, -28}, {-66, -28}, {-66, 48}, {-50, 48}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {120, 80}}, initialScale = 0.1), graphics = {Text(origin = {-56, -50}, lineColor = {238, 46, 47}, extent = {{30, -4}, {98, -20}}, textString = "torque constant=1.564 Nm/A"), Rectangle(lineColor = {238, 46, 47}, pattern = LinePattern.Dash, extent = {{6, 62}, {54, 26}}), Text(lineColor = {238, 46, 47}, pattern = LinePattern.Dash, extent = {{52, 70}, {8, 66}}, textString = "simulates inverter")}),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<p>Permanent magnet synchronous machine drive with MTPA control specifically designed for isotropic machines.</p>
<p>Initially the transient has low speed and no Id is needed: the control chose therefore Id=0.</p>
<p>Later speed increases and the control logic requires a negative Id to control machine voltage.</p>
<p>Here no control on current amplitude is implemented, and therefore during the end of the simulation current slightly overcomes machine&apos;s nominal value.</p>
</html>"),Icon(coordinateSystem(extent = {{-100, -80}, {120, 80}})),
          experiment(StopTime = 4, Interval = 0.001),
          __OpenModelica_commandLineOptions = "");
      end SmaDriveFW;

      model SmaDriveLim
        //  extends Modelica.Icons.Example;
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.29, phi(fixed = true, start = 0), w(fixed = true, start = 0)) annotation (
          Placement(transformation(extent = {{70, 84}, {90, 104}})));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(transformation(extent = {{86, 132}, {106, 152}})));
        Modelica.Electrical.Machines.BasicMachines.SynchronousInductionMachines.SM_PermanentMagnet smpm1(useDamperCage = false, Lmd = 1.91e-3, Lmq = 1.91e-3) annotation (
          Placement(transformation(extent = {{28, 84}, {48, 104}}, rotation = 0)));
        Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox1(terminalConnection = "Y") annotation (
          Placement(transformation(extent = {{28, 112}, {48, 132}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sources.SignalCurrent signalCurr1(final m = 3) annotation (
          Placement(transformation(origin = {38, 146}, extent = {{-10, 10}, {10, -10}}, rotation = 270)));
        Modelica.Electrical.MultiPhase.Basic.Star star1(final m = 3) annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = 180, origin = {70, 156})));
        Modelica.Blocks.Sources.Constant uDC(k = 200) annotation (
          Placement(transformation(extent = {{-98, 136}, {-78, 156}})));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor wMeccSens annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {60, 80})));
        Modelica.Blocks.Continuous.Integrator integrator annotation (
          Placement(transformation(extent = {{10, -10}, {-10, 10}}, rotation = -90, origin = {-12, 98})));
        SMArelated.FromPark fromPark(p = smpm1.p) annotation (
          Placement(transformation(extent = {{-22, 136}, {-2, 156}})));
        Modelica.Electrical.Analog.Basic.Ground groundM1 annotation (
          Placement(transformation(origin = {12, 118}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        SMArelated.MTPAal myMTPA(Umax = 100, Ipm = smpm1.permanentMagnet.Ie, pp = smpm1.p, Rs = smpm1.Rs, Ld = smpm1.Lmd, Lq = smpm1.Lmq) annotation (
          Placement(visible = true, transformation(extent = {{-50, 136}, {-30, 156}}, rotation = 0)));
        Modelica.Blocks.Continuous.FirstOrder firstOrder1[3](T = 0.2e-4 * {1, 1, 1}) annotation (
          Placement(visible = true, transformation(origin = {16, 146}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Blocks.Sources.Trapezoid tqRef(rising = 2, period = 1e6, amplitude = 180, falling = 2, startTime = 1, width = 4) annotation (
          Placement(transformation(extent = {{-98, 100}, {-78, 120}})));
        Modelica.Mechanics.Rotational.Sources.QuadraticSpeedDependentTorque tRes(tau_nominal = -150, w_nominal(displayUnit = "rpm") = 157.07963267949) annotation (
          Placement(transformation(extent = {{116, 84}, {96, 104}})));
      equation
        connect(myMTPA.wMech, integrator.u) annotation (
          Line(points = {{-52, 140}, {-60, 140}, {-60, 76}, {-12, 76}, {-12, 86}}, color = {0, 0, 127}));
        connect(fromPark.Xq, myMTPA.Iq) annotation (
          Line(points = {{-24, 140}, {-29, 140}}, color = {0, 0, 127}));
        connect(fromPark.Xd, myMTPA.Id) annotation (
          Line(points = {{-24, 152}, {-29, 152}}, color = {0, 0, 127}));
        connect(myMTPA.uDC, uDC.y) annotation (
          Line(points = {{-52, 146}, {-77, 146}}, color = {0, 0, 127}));
        connect(terminalBox1.plug_sn, smpm1.plug_sn) annotation (
          Line(points = {{32, 116}, {32, 104}}, color = {0, 0, 255}));
        connect(terminalBox1.plug_sp, smpm1.plug_sp) annotation (
          Line(points = {{44, 116}, {44, 104}}, color = {0, 0, 255}));
        connect(star1.plug_p, signalCurr1.plug_p) annotation (
          Line(points = {{60, 156}, {38, 156}}, color = {0, 0, 255}));
        connect(star1.pin_n, ground.p) annotation (
          Line(points = {{80, 156}, {96, 156}, {96, 152}}, color = {0, 0, 255}));
        connect(inertia.flange_a, smpm1.flange) annotation (
          Line(points = {{70, 94}, {48, 94}}, color = {0, 0, 0}));
        connect(signalCurr1.plug_n, terminalBox1.plugSupply) annotation (
          Line(points = {{38, 136}, {38, 118}}, color = {0, 0, 255}));
        connect(wMeccSens.flange, smpm1.flange) annotation (
          Line(points = {{60, 90}, {60, 94}, {48, 94}}, color = {0, 0, 0}));
        connect(wMeccSens.w, integrator.u) annotation (
          Line(points = {{60, 69}, {60, 64}, {10, 64}, {10, 76}, {-12, 76}, {-12, 86}}, color = {0, 0, 127}));
        connect(integrator.y, fromPark.phi) annotation (
          Line(points = {{-12, 109}, {-12, 134}}, color = {0, 0, 127}));
        connect(groundM1.p, terminalBox1.starpoint) annotation (
          Line(points = {{22, 118}, {28, 118}}, color = {0, 0, 255}));
        connect(firstOrder1.u, fromPark.y) annotation (
          Line(points = {{6.4, 146}, {-1, 146}}, color = {0, 0, 127}));
        connect(firstOrder1.y, signalCurr1.i) annotation (
          Line(points = {{24.8, 146}, {26, 146}}, color = {0, 0, 127}));
        connect(tqRef.y, myMTPA.torqueReq) annotation (
          Line(points = {{-77, 110}, {-68, 110}, {-68, 152}, {-52, 152}}, color = {0, 0, 127}));
        connect(inertia.flange_b, tRes.flange) annotation (
          Line(points = {{90, 94}, {96, 94}}, color = {0, 0, 0}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, 40}, {120, 180}}), graphics = {Rectangle(extent = {{4, 166}, {52, 130}}, lineColor = {238, 46, 47}, pattern = LinePattern.Dash), Text(extent = {{50, 172}, {6, 170}}, lineColor = {238, 46, 47}, pattern = LinePattern.Dash, textString = "simulates inverter")}),
          __Dymola_experimentSetupOutput,
          Documentation(info = "<html>
<p>Permanent magnet synchronous machine drive with MTPA control specifically designed for isotropic machines.</p>
<p>Initially the transient has low speed and no Id is needed: the control chose therefore Id=0.</p>
<p>Later speed increases and the control logic requires a negative Id to control machine voltage.</p>
<p>Here control on current amplitude <b>is </b>implemented, which becomes active during the central part of the simulation; in this case only part of the requested toque is delivered.</p>
</html>"),Icon(coordinateSystem(extent = {{-100, 40}, {120, 180}})),
          experiment(StopTime = 10, Interval = 0.001),
          __OpenModelica_commandLineOptions = "");
      end SmaDriveLim;

      model tqFollowing "Compares U/f=cost and mains start-ups"
        //
        import Modelica.Constants.pi;
        Modelica.Electrical.Machines.Utilities.TerminalBox terminalBox annotation (
          Placement(visible = true, transformation(extent = {{4, 14}, {24, 34}}, rotation = 0)));
        Modelica.Electrical.Machines.BasicMachines.AsynchronousInductionMachines.AIM_SquirrelCage aimc annotation (
          Placement(visible = true, transformation(extent = {{4, -16}, {24, 4}}, rotation = 0)));
        Modelica.Electrical.Analog.Basic.Ground ground annotation (
          Placement(visible = true, transformation(extent = {{-98, -36}, {-78, -16}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Basic.Star star annotation (
          Placement(visible = true, transformation(origin = {-88, 8}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
        Modelica.Electrical.MultiPhase.Sensors.AronSensor pUp annotation (
          Placement(visible = true, transformation(extent = {{-38, 14}, {-20, 32}}, rotation = 0)));
        Modelica.Electrical.MultiPhase.Sources.SignalVoltage signalV annotation (
          Placement(visible = true, transformation(origin = {-58, 23}, extent = {{-10, -9}, {10, 9}}, rotation = 180)));
        Modelica.Mechanics.Rotational.Sensors.SpeedSensor speedSensor annotation (
          Placement(visible = true, transformation(origin = {61, -25}, extent = {{-7, -7}, {7, 7}}, rotation = 270)));
        Modelica.Electrical.MultiPhase.Sensors.CurrentSensor iUp annotation (
          Placement(visible = true, transformation(origin = {-6, 40}, extent = {{-8, -8}, {8, 8}}, rotation = 0)));
        Modelica.Mechanics.Rotational.Components.Inertia inertia(J = 0.5) annotation (
          Placement(visible = true, transformation(extent = {{34, -16}, {54, 4}}, rotation = 0)));
        EHPTlib.ElectricDrives.ASMArelated.ControlLogic logic(
          Lstray=aimc.Lssigma + aimc.Lrsigma,
          Rr=aimc.Rr,
          Rs=aimc.Rs,
          iMax=150,
          pp=aimc.p,
          uBase=100*sqrt(3),
          weBase=314.16,
          wmMax=314.16/2) annotation (Placement(visible=true, transformation(
                extent={{-18,-54},{-38,-34}}, rotation=0)));
        EHPTlib.ElectricDrives.ASMArelated.GenSines genSines annotation (
            Placement(visible=true, transformation(
              origin={-59,-6},
              extent={{11,-10},{-11,10}},
              rotation=-90)));
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
          Line(points = {{-16.1, -44.1}, {-10, -44.1}, {-10, -44}, {-1, -44}}, color = {0, 0, 127}));
        connect(genSines.Westar, logic.Westar) annotation (
          Line(points = {{-53.1, -18.43}, {-54.1, -18.43}, {-54.1, -36.43}, {-52.6, -36.43}, {-52.6, -38}, {-39, -38}}, color = {0, 0, 127}));
        connect(genSines.U, signalV.v) annotation (
          Line(points = {{-59, 6.1}, {-58, 6.1}, {-58, 12.2}}, color = {0, 0, 127}));
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
        connect(logic.Wm, speedSensor.w) annotation (
          Line(points = {{-28.1, -55.3}, {-28.1, -62.3}, {61, -62.3}, {61, -32.7}}, color = {0, 0, 127}));
        connect(pUp.plug_p, signalV.plug_p) annotation (
          Line(points = {{-38, 23}, {-48, 23}, {-48, 23}, {-48, 23}}, color = {0, 0, 255}));
        connect(pUp.plug_n, iUp.plug_p) annotation (
          Line(points = {{-20, 23}, {-18, 23}, {-18, 40}, {-14, 40}, {-14, 40}}, color = {0, 0, 255}));
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
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 60}}, preserveAspectRatio = false), graphics = {Rectangle(origin = {-57, 26}, lineColor = {255, 0, 0}, pattern = LinePattern.Dash, extent = {{-15, 10}, {15, -48}}), Text(origin = {-30, -1}, extent = {{-8, 3}, {8, -3}}, textString = "inverter")}),
          experiment(StartTime = 0, StopTime = 12, Tolerance = 0.0001, Interval = 0.0024),
          __OpenModelica_commandLineOptions = "");
      end tqFollowing;
    end TestingModels;

    package ASMArelated "Models related to Asynchronous Machine Drives"
      model DWToI "Delta Omega to I"
        // follows eq. 12.13 from FEPE Book
        parameter Modelica.SIunits.Resistance Rr "rotor resistance in stato units";
        parameter Integer pp "pole pairs";
        parameter Real Kw "constant Komega of FEPE Book";
        parameter Modelica.SIunits.Current iMax "maximum calue of rms current";
        parameter Modelica.SIunits.Inductance Lstray "combined stray inductance";
        Modelica.SIunits.Current I "current before limitation";
        Modelica.Blocks.Interfaces.RealInput u annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealOutput y annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Sources.RealExpression I_(y = I) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}})));
        Modelica.Blocks.Nonlinear.Limiter limiter(uMax = iMax, uMin = 0) annotation (
          Placement(transformation(extent = {{42, -10}, {62, 10}})));
      equation
        I = sqrt(u ^ 2 * Kw ^ 2 / ((pp * u * Lstray) ^ 2 + Rr ^ 2));
        connect(I_.y, limiter.u) annotation (
          Line(points = {{11, 0}, {26, 0}, {40, 0}}, color = {0, 0, 127}));
        connect(y, limiter.y) annotation (
          Line(points = {{110, 0}, {86, 0}, {63, 0}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -40}, {100, 40}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-62, -62}, {-62, 64}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-70, 54}, {-62, 66}, {-56, 54}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-76, -54}, {68, -54}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-7, -6}, {1, 6}, {7, -6}}, color = {0, 0, 127}, smooth = Smooth.None, origin = {65, -54}, rotation = 270), Line(points = {{-68, -62}, {2, 28}, {54, 28}}, color = {0, 0, 127}, smooth = Smooth.None), Text(extent = {{-50, 68}, {-14, 40}}, lineColor = {0, 0, 127}, textString = "I"), Line(points = {{-69, 27}, {-53, 27}}, color = {0, 0, 127}, smooth = Smooth.None), Text(extent = {{-100, 144}, {98, 106}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name")}),
          __OpenModelica_commandLineOptions = "");
      end DWToI;

      block GenSines "Generates three-phase sine waves"
        import Modelica.Constants.pi;
        Modelica.Blocks.Interfaces.RealInput Westar annotation (
          Placement(transformation(extent = {{-140, 28}, {-100, 68}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 0, origin = {-113, 59})));
        Modelica.Blocks.Interfaces.RealOutput U[3] annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Interfaces.RealInput Ustar "RMS phase" annotation (
          Placement(transformation(extent = {{-140, -60}, {-100, -20}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 0, origin = {-113, -59})));
        Modelica.Blocks.Math.Add add1[3] annotation (
          Placement(transformation(extent = {{0, 38}, {20, 58}})));
        Modelica.Blocks.Math.Sin sin[3] annotation (
          Placement(transformation(extent = {{34, 38}, {54, 58}})));
        Modelica.Blocks.Continuous.Integrator integrator annotation (
          Placement(transformation(extent = {{-72, 38}, {-52, 58}})));
        Modelica.Blocks.Routing.Replicator replicator(nout = 3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {60, 8})));
        Modelica.Blocks.Math.Product product[3] annotation (
          Placement(transformation(extent = {{72, 28}, {92, 48}})));
        Modelica.Blocks.Math.Gain ToPeak(k = sqrt(2)) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {60, -22})));
        Modelica.Blocks.Sources.Constant phase[3](k = 2 * pi / 3 * {0, -1, 1}) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-10, 8})));
        Modelica.Blocks.Routing.Replicator replicator1(nout = 3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-30, 48})));
      equation
        connect(sin.u, add1.y) annotation (
          Line(points = {{32, 48}, {21, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(product.y, U) annotation (
          Line(points = {{93, 38}, {102, 38}, {102, 0}, {110, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(product.u2, replicator.y) annotation (
          Line(points = {{70, 32}, {60, 32}, {60, 19}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(ToPeak.y, replicator.u) annotation (
          Line(points = {{60, -11}, {60, -4}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(sin.y, product.u1) annotation (
          Line(points = {{55, 48}, {62, 48}, {62, 44}, {70, 44}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(add1.u1, replicator1.y) annotation (
          Line(points = {{-2, 54}, {-10, 54}, {-10, 48}, {-19, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(add1.u2, phase.y) annotation (
          Line(points = {{-2, 42}, {-10, 42}, {-10, 19}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(replicator1.u, integrator.y) annotation (
          Line(points = {{-42, 48}, {-51, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(integrator.u, Westar) annotation (
          Line(points = {{-74, 48}, {-82, 48}, {-88, 48}, {-120, 48}}, color = {0, 0, 127}));
        connect(ToPeak.u, Ustar) annotation (
          Line(points = {{60, -34}, {60, -34}, {60, -40}, {-120, -40}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Rectangle(lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Text(lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 144}, {98, 106}}, textString = "%name"), Line(points = {{-4, 28}, {8, 48}, {28, 48}, {48, 8}, {70, 8}, {82, 28}}), Line(points = {{-6, 4}, {6, 24}, {26, 24}, {46, -16}, {68, -16}, {80, 4}}), Line(points = {{-8, -16}, {4, 4}, {24, 4}, {44, -36}, {66, -36}, {78, -16}}), Rectangle(extent = {{-88, 10}, {-60, -4}}), Polygon(points = {{-60, 18}, {-34, 4}, {-60, -10}, {-60, 18}}), Text(lineColor = {0, 0, 127}, extent = {{-60, -78}, {-102, -46}}, textString = "U"), Text(origin = {0, -4}, lineColor = {0, 0, 127}, extent = {{-62, 48}, {-98, 78}}, textString = "W")}),
          Documentation(info = "<html>
<p>This class produces a three-phase voltage system to variable-frequency control of an asynchronous motor.</p>
<p>The output voltages constitute a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</p>
<p>Wel=Wmecc*PolePairs+DeltaWel</p>
<p>U=U0+(Un-U0)*(Wel)/Wnom</p>
<p>where:</p>
<p><ul>
<li>U0, Un U, are initial, nominal actual voltage amplitudes</li>
<li>Wmecc, Wel are machine (mechanical) and supply (electrical) angular speeds</li>
<li>PolePairs are the number of machine pole pairs</li>
<li>DeltaWel is an input variable and depends on the desired torque</li>
</ul></p>
</html>"));
      end GenSines;

      model TorqueToDW "Torque to Delta Omega"
        parameter Modelica.SIunits.Resistance Rr "Rotor resistance in stato units";
        parameter Integer pp "Pole pairs";
        parameter Real Kw "Constant Komega of FEPE Book";
        parameter Modelica.SIunits.AngularVelocity wmBase = 314.16 "Base electric frequency";
        parameter Modelica.SIunits.Inductance Lstray "Combined stray inductance";
        //The following is 12.11 of FEPE book, when U1=Kw*W (LS stands for low speed)
        Modelica.SIunits.Torque Tmax;
      public
        Modelica.Blocks.Interfaces.RealInput u annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealOutput y annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Interfaces.RealInput Wm annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.BooleanOutput tauIsMax annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = -90, origin = {0, -110})));
      equation
        if Wm < wmBase then
          Tmax = 3 * Kw ^ 2 / (2 * pp * Lstray);
        else
          //The following is 12.11 of FEPE book
          Tmax = 3 * (Kw * wmBase) ^ 2 / (2 * pp * Wm ^ 2 * Lstray);
        end if;
        //Se la coppia richiesta supera la massima mi attesto al deltaW
        //che corrisponde al picco di coppia
        if u > Tmax then
          Tmax = 3 * Rr * y * Kw ^ 2 / ((pp * y * Lstray) ^ 2 + Rr ^ 2);
          //    y = Rr / (pp*Lstray);
          tauIsMax = true;
        elseif u < (-Tmax) then
          -Tmax = 3 * Rr * y * Kw ^ 2 / ((pp * y * Lstray) ^ 2 + Rr ^ 2);
          //    y = -Rr / (pp * Lstray);
          tauIsMax = true;
        else
          /* La seguente riga è eq. 12.14 di FEPE Book. Naturalmente essa 
        determina una richiesta di coppia corretta a pieno flusso, zona nella quale 
        vale la 12.14, mentre è approssimata in deflussaggio. Peraltro essendo 
        normalmente il controllo in velocità in retroazione, in questo modello 
        semplificato si accetta questo tipo di delta_omega, che determina una 
        potenza decrescente invece che costante come potrebbe essere.       
      */
          u = 3 * Rr * y * Kw ^ 2 / ((pp * y * Lstray) ^ 2 + Rr ^ 2);
          /*  Si potrebbe completare il controllo facendo in modo che al di sopra della 
        velocità base si applichi la formula 12.10 di FEPE in cui U1=Kw*wmBase.
        Al posto di W0 si può mettere Wm+y.
        Le formule si complicano e quindi per ragioni didattiche non lo facciamo.
        
        Si riporta comunque qui sotto un'implementazione provvisoria con coppia 
        valida in tutte le regioni, da ultimare e verificare:
        */
          //u=3*(Kw*wmBase)^2*Rr*y/(y^2*pp^2*(Wm+y)^2*Lstray^2+Rr^2*(Wm+y));
          tauIsMax = false;
        end if;
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 144}, {98, 106}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Line(points = {{-67, -26}, {-51, -26}, {-51, -22}, {-49, -15}, {-40, -8}, {18, 25}, {26, 32}, {29, 37}, {29, 42}, {49, 42}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-66, 8}, {78, 8}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-12, -44}, {-12, 82}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-20, 72}, {-12, 84}, {-6, 72}}, color = {0, 0, 127}, smooth = Smooth.None), Text(extent = {{16, 72}, {52, 44}}, lineColor = {0, 0, 127}, textString = "DW"), Line(points = {{-7, -6}, {1, 6}, {7, -6}}, color = {0, 0, 127}, smooth = Smooth.None, origin = {75, 8}, rotation = 270), Text(extent = {{60, -6}, {96, -34}}, lineColor = {0, 0, 127}, textString = "T")}));
      end TorqueToDW;

      block ControlLogic "Follows upper fig. 12.15 from FEPE Book"
        import Modelica.Constants.pi;
        parameter Modelica.SIunits.Resistance Rr(start = 0.04) "Rotor resistance";
        parameter Modelica.SIunits.Resistance Rs(start = 0.03) "Stator resistance";
        parameter Modelica.SIunits.Voltage uBase(start = 400) "Base phase-to-phase RMS voltage";
        parameter Modelica.SIunits.AngularVelocity weBase = 314.16 "Base electric frequency";
        parameter Modelica.SIunits.Inductance Lstray(start = 0.2036 / weBase) "Combined stray inductance";
        parameter Modelica.SIunits.AngularVelocity wmMax = 314.16 "Maximum mechanical Speed";
        parameter Integer pp(min = 1, start = 2) "number of pole pairs (Integer)";
        //La seguente keyword final consente fra l'altro di far scomparire questi parametri dalla maschera.
        final parameter Real Kw(fixed = true) = uBase / sqrt(3) / (weBase / pp) "Ratio U/Wmecc";
        Modelica.Blocks.Interfaces.RealInput Wm annotation (
          Placement(transformation(extent = {{-160, -80}, {-120, -40}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 90, origin = {1, -113})));
        Modelica.Blocks.Interfaces.RealOutput Ustar annotation (
          Placement(transformation(extent = {{120, -50}, {140, -30}}), iconTransformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Interfaces.RealInput Tstar annotation (
          Placement(transformation(extent = {{-160, 40}, {-120, 80}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 0, origin = {-119, -1})));
        Modelica.Blocks.Math.Add add annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-38, 56})));
        Modelica.Blocks.Nonlinear.Limiter limWm(limitsAtInit = true, uMax = wmMax, uMin = uBase / sqrt(3) / 100 / Kw) annotation (
          Placement(transformation(extent = {{0, 50}, {20, 70}})));
        Modelica.Blocks.Interfaces.RealOutput Westar annotation (
          Placement(transformation(extent = {{120, 50}, {140, 70}}), iconTransformation(extent = {{100, 50}, {120, 70}})));
        ASMArelated.TorqueToDW tauToDW(Rr = Rr, pp = pp, Kw = Kw, Lstray = Lstray, wmBase = weBase / pp) annotation (
          Placement(transformation(extent = {{-100, 50}, {-80, 70}})));
        Modelica.Blocks.Math.Gain gain(k = pp) annotation (
          Placement(transformation(extent = {{62, 50}, {82, 70}})));
        Modelica.Blocks.Math.Add add1(k1 = Rs, k2 = Kw) annotation (
          Placement(transformation(extent = {{40, 10}, {60, -10}})));
        Modelica.Blocks.Nonlinear.Limiter limU(uMax = uBase / sqrt(3), uMin = 0) annotation (
          Placement(transformation(extent = {{76, -10}, {96, 10}})));
        Modelica.Blocks.Logical.GreaterThreshold toWeakening(threshold = limU.uMax) annotation (
          Placement(visible = true, transformation(origin = {66, -36}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Logical.GreaterThreshold toMaxSpeed(threshold = limWm.uMax) annotation (
          Placement(visible = true, transformation(origin = {-10, 28}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Sources.RealExpression toIstar(y = sqrt(abs(Tstar * tauToDW.y / (3 * Rs)))) annotation (
          Placement(transformation(extent = {{-30, -18}, {8, 0}})));
      equation
        connect(toMaxSpeed.u, limWm.u) annotation (
          Line(points = {{-10, 40}, {-10, 40}, {-10, 60}, {-2, 60}, {-2, 60}, {-2, 60}}, color = {0, 0, 127}));
        connect(limWm.u, add.y) annotation (
          Line(points = {{-2, 60}, {-12, 60}, {-12, 72}, {-38, 72}, {-38, 67}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(Tstar, tauToDW.u) annotation (
          Line(points = {{-140, 60}, {-122, 60}, {-122, 66}, {-102, 66}}, color = {0, 0, 127}));
        connect(tauToDW.y, add.u1) annotation (
          Line(points = {{-79, 60}, {-79, 60}, {-74, 60}, {-74, 44}, {-44, 44}}, color = {0, 0, 127}));
        connect(add.u2, Wm) annotation (
          Line(points = {{-32, 44}, {-32, 44}, {-32, 14}, {-110, 14}, {-110, -18}, {-110, -18}, {-110, -60}, {-140, -60}}, color = {0, 0, 127}));
        connect(Westar, gain.y) annotation (
          Line(points = {{130, 60}, {106, 60}, {83, 60}}, color = {0, 0, 127}));
        connect(gain.u, limWm.y) annotation (
          Line(points = {{60, 60}, {50, 60}, {20, 60}, {21, 60}}, color = {0, 0, 127}));
        connect(add1.y, limU.u) annotation (
          Line(points = {{61, 0}, {74, 0}}, color = {0, 0, 127}));
        connect(limU.y, Ustar) annotation (
          Line(points = {{97, 0}, {102, 0}, {102, -40}, {130, -40}}, color = {0, 0, 127}));
        connect(tauToDW.Wm, Wm) annotation (
          Line(points = {{-102, 54}, {-110, 54}, {-110, -60}, {-140, -60}}, color = {0, 0, 127}));
        connect(add1.u2, limWm.y) annotation (
          Line(points = {{38, 6}, {34, 6}, {34, 60}, {21, 60}}, color = {0, 0, 127}));
        connect(toWeakening.u, limU.u) annotation (
          Line(points = {{66, -24}, {66, 0}, {74, 0}}, color = {0, 0, 127}));
        connect(toIstar.y, add1.u1) annotation (
          Line(points = {{9.9, -9}, {22, -9}, {22, -6}, {38, -6}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-120, -80}, {120, 80}}, initialScale = 0.1), graphics = {Text(origin = {0, -4}, lineColor = {0, 0, 127}, extent = {{-48, -12}, {22, -22}}, textString = "This is the first equality \nin 12.14 of FEPE Book"), Text(origin = {0, -16}, lineColor = {0, 0, 127}, extent = {{-48, -12}, {22, -22}}, textString = "The sqrt argument might become negative
because of roundoff errors. This justifies abs()")}),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{-64, -54}, {-64, 72}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-72, 62}, {-64, 74}, {-58, 62}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-78, -46}, {66, -46}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-7, -6}, {1, 6}, {7, -6}}, color = {0, 0, 127}, smooth = Smooth.None, origin = {59, -45}, rotation = 270), Line(points = {{-70, -32}, {0, 36}, {52, 36}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-71, -27}, {-55, -27}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-71, 35}, {-55, 35}}, color = {0, 0, 127}, smooth = Smooth.None), Line(points = {{-2, -18}, {-2, -50}, {-2, -40}}, color = {0, 0, 127}, smooth = Smooth.None), Text(extent = {{-102, 144}, {96, 106}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Text(extent = {{58, 72}, {94, 44}}, lineColor = {0, 0, 127}, textString = "W"), Text(extent = {{64, -48}, {96, -74}}, lineColor = {0, 0, 127}, textString = "U")}),
          Documentation(info = "<html>
<p>This class produces a three-phase voltage system to variable-frequency control of an asynchronous motor.</p>
<p>The output voltages constitute a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</p>
<p>Wel=Wmecc*PolePairs+DeltaWel</p>
<p>U=U0+(Un-U0)*(Wel)/Wnom</p>
<p>where:</p>
<ul>
<li>U0, Un U, are initial, nominal and actual voltage amplitudes</li>
<li>Wmecc, Wel are machine (mechanical) and supply (electrical) angular speeds</li>
<li>PolePairs are the number of machine pole pairs</li>
<li>DeltaWel is the difference between synchnonous angular speed and mechichal speed (divided by pole pairs). It is a non-linear function of the input  torque.</li>
</ul>
</html>"),experiment(StopTime = 500, Interval = 0.1));
      end ControlLogic;
      annotation (
        Icon(graphics = {Ellipse(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 0.5, extent = {{-100, 100}, {100, -98}}, endAngle = 360), Text(origin = {0, 1.53849}, lineColor = {28, 108, 200}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 0.5, extent = {{-100, 58.4615}, {100, -61.5385}}, textString = "A", textStyle = {TextStyle.Bold})}));
    end ASMArelated;

    package SMArelated "Models related to Synchronos Machine Electric Drives"
      model MTPAi "MTPA logic for an isotropic machine"
        // Non-Ascii Symbol to cause UTF-8 saving by Dymola: €
        //Implements block 1 of figure 11.28 of FEPE book
        import PI = Modelica.Constants.pi;
        parameter Modelica.SIunits.Current Ipm = 1.5;
        parameter Integer pp = 1 "Pole pairs";
        parameter Modelica.SIunits.Resistance Rs "Stator resistance";
        parameter Modelica.SIunits.Inductance Ld "Direct-axis inductance";
        parameter Modelica.SIunits.Voltage Umax "Max rms voltage per phase to the motor";
      protected
        parameter Modelica.SIunits.Voltage UmaxPk = sqrt(2) * Umax "Nominal voltage (peak per phase)";
        //The following voltage Ulim is set to be equal to Udc without margins
        //since this model implementation allows it. In practice, obviously
        //some coefficient will be included since the voltage control is not
        // "perfect" and instantaneous
        parameter Modelica.SIunits.MagneticFlux Psi = Ipm * Ld "psi=Ipm*Ld";
        Modelica.SIunits.Current absI = sqrt(Id ^ 2 + Iq ^ 2);
      public
        Modelica.SIunits.Voltage Ulim = min(uDC / sqrt(3), UmaxPk) "tensione limite (fase-picco) fa attivare il deflussaggio;";
        Modelica.SIunits.Angle gammaStar(start = 0);
        //  Real Is "corrente rapportata al valore nominale (es. rms/rms)";
        Modelica.SIunits.Voltage Vd, Vq;
        Modelica.SIunits.Current IdFF "Id FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Current IqFF "Iq FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Voltage VdFF "Vd FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Voltage VqFF "Vq FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Current IparkFF(start = 0) "Ipark amplitude FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Voltage VparkFF "Vpark amplitude FullFlux (i.e. before flux weaking evaluation)";
        Modelica.SIunits.Current Ipark(start = 70) "Ipark amplitude (=sqrt(Id^2+Iq^2))";
        Modelica.SIunits.Voltage Vpark "Vpark amplitude (=sqrt(Vd^2+Vq^2))";
        Modelica.SIunits.AngularVelocity w = pp * wMech;
        Real weakening;
        //weakening should be boolean. It is assumed to be real because otherwise this
        //model will not work under OpenModelica 1.9.2.
        Modelica.Blocks.Interfaces.RealInput torqueReq annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}}), iconTransformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealInput wMech annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}}), iconTransformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.RealOutput Id annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}}), iconTransformation(extent = {{100, 50}, {120, 70}})));
        Modelica.Blocks.Interfaces.RealOutput Iq annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}}), iconTransformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Interfaces.RealInput uDC "DC voltage" annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}})));
      equation
        //Computations with full flux.
        //Computation of  Id, Iq, Vd, Vq, V
        IparkFF = torqueReq / (1.5 * pp * Psi);
        IdFF = 0;
        IqFF = IparkFF;
        VdFF = Rs * IdFF - w * Ld * IqFF;
        VqFF = Rs * IqFF + w * Psi;
        VparkFF = sqrt(VdFF ^ 2 + VqFF ^ 2);
        if VparkFF < Ulim then
          weakening = 0;
          //weakening should be boolean. It is assumed to be real because otherwise this
          //model will not work under OpenModelica 1.9.2.
          0 = gammaStar;
          Id = IdFF;
          Iq = IqFF;
          Vd = VdFF;
          Vq = VqFF;
          Vpark = VparkFF;
        else
          weakening = 1;
          //weakening should be boolean. It is assumed to be real because otherwise this
          //model will not work under OpenModelica 1.9.2.
          Id = -Ipark * sin(gammaStar);
          Iq = Ipark * cos(gammaStar);
          Vd = Rs * Id - w * Ld * Iq;
          Vq = Rs * Iq + w * (Psi + Ld * Id);
          Vpark = sqrt(Vd ^ 2 + Vq ^ 2);
          Vpark = Ulim;
          //   gammaFilt+tauFilt*der(gammaFilt)=gammaStar;
        end if;
        torqueReq = 1.5 * pp * Psi * Ipark * cos(gammaStar);
        assert(gammaStar < 0.98 * PI / 2, "\n***\nmaximum gamma reached\n***\n");
        annotation (
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 142}, {100, 106}}, lineColor = {0, 0, 127}, textString = "%name"), Text(extent = {{-98, 28}, {98, -28}}, lineColor = {0, 0, 127}, textString = "MTPAi")}),
          Diagram(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})));
      end MTPAi;

      model MTPAa "MTPA logic for a generic (anisotropic) machine"
        // Non-Ascii Symbol to cause UTF-8 saving by Dymola: €
        parameter Modelica.SIunits.Current Ipm = 1.5 "Permanent magnet current";
        parameter Integer pp = 1 "Pole pairs";
        parameter Modelica.SIunits.Resistance Rs = 0.02 "Stator resistance";
        parameter Modelica.SIunits.Inductance Ld = 0.4 "Basic direct-axis inductance";
        parameter Modelica.SIunits.Inductance Lq = 1.1 "Basic quadrature-axis inductance";
        parameter Modelica.SIunits.Voltage Umax = 100 "Max rms voltage per phase to the motor";
      protected
        parameter Modelica.SIunits.Voltage UmaxPk = sqrt(2) * Umax "nominal voltage (peak per phase)";
        //The following voltage Ulimi is set to be equal to Udc without margins
        //since this model implementation allows it. In pcactice, obviously
        //some safety coefficient will be included since the voltage control is not
        // "perfect" and instantaneous
      public
        Modelica.SIunits.Voltage Ulim = min(uDC / sqrt(3), UmaxPk) "tensione limite (fase-picco) fa attivare il deflussaggio;";
        Modelica.SIunits.Angle gammaFF(start = 0), gammaStar(start = 0);
        //  Real Is "corrente rapportata al valore nominale (es. rms/rms)";
        Modelica.SIunits.Voltage Vd, Vq;
        Modelica.SIunits.Current IdFF "Id FullFlux (i.e. before flux weaking evalation)";
        Modelica.SIunits.Current IqFF "Iq FullFlux (i.e. before flux weaking evalation)";
        Modelica.SIunits.Voltage VdFF "Vd FullFlux (i.e. before flux weaking evalation)";
        Modelica.SIunits.Voltage VqFF "Vq FullFlux (i.e. before flux weaking evalation)";
        Modelica.SIunits.Current IparkFF(start = 0) "Ipark amplitude FullFlux (i.e. before flux weaking evalation)";
        Modelica.SIunits.Voltage VparkFF "Vpark amplitude FullFlux (i.e. before flux weaking evalation)";
        //  Real Ipark(start = 70) "Ipark amplitude (=sqrt(Id^2+Iq^2))";
        Modelica.SIunits.Voltage Vpark "Vpark amplitude (=sqrt(Vd^2+Vq^2))";
        Modelica.SIunits.Torque T1 "Torque due to PM field";
        Modelica.SIunits.Torque T2 "Torque due to anisotropy (reluctance torque)";
        Modelica.SIunits.AngularVelocity w = pp * wMech;
        Real weakening;
        //weakening should be boolean. It is assumed to be real because otherwise this
        //model will not work under OpenModelica 1.9.2.
      protected
        parameter Real Psi = Ipm * Ld "psi=Ipm*Ld";
      public
        Modelica.Blocks.Interfaces.RealInput torqueReq annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}}), iconTransformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealInput wMech annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}}), iconTransformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.RealOutput Id annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}}), iconTransformation(extent = {{100, 50}, {120, 70}})));
        Modelica.Blocks.Interfaces.RealOutput Iq annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}}), iconTransformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Interfaces.RealInput uDC "DC voltage" annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealOutput Ipark annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {0, 110}), iconTransformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {0, 110})));
      equation
        //Computations with full flux.
        //The following two equations determine IparkFF and gammaFF:
        0 = (-Psi * sin(gammaFF)) + (Lq - Ld) * IparkFF * cos(2 * gammaFF);
        torqueReq = 1.5 * pp * (Psi * IparkFF * cos(gammaFF) + (Lq - Ld) / 2 * IparkFF ^ 2 * sin(2 * gammaFF));
        //Computation of  Id, Iq, Vd, Vq, V
        IdFF = -IparkFF * sin(gammaFF);
        IqFF = IparkFF * cos(gammaFF);
        VdFF = Rs * IdFF - w * Lq * IqFF;
        VqFF = Rs * IqFF + w * (Psi + Ld * IdFF);
        VparkFF = sqrt(VdFF ^ 2 + VqFF ^ 2);
        if VparkFF < Ulim then
          weakening = 0;
          //weakening should be boolean. It is assumed to be real because otherwise this
          //model will not work under OpenModelica 1.9.2.
          0 = (-Psi * sin(gammaStar)) + (Lq - Ld) * IparkFF * cos(2 * gammaStar);
          Id = IdFF;
          Iq = IqFF;
          Vd = VdFF;
          Vq = VqFF;
          Vpark = VparkFF;
        else
          weakening = 1;
          //weakening should be boolean. It is assumed to be real because otherwise this
          //model will not work under OpenModelica 1.9.2.
          Id = -Ipark * sin(gammaStar);
          Iq = Ipark * cos(gammaStar);
          Vd = Rs * Id - w * Lq * Iq;
          Vq = Rs * Iq + w * (Psi + Ld * Id);
          Vpark = sqrt(Vd ^ 2 + Vq ^ 2);
          Vpark = Ulim;
          //   gammaFilt+tauFilt*der(gammaFilt)=gammaStar;
        end if;
        //  T1 = 1.5*pp*Psi*Ipark*cos(gammaFilt);
        //  T2 = 1.5*pp*(Lq - Ld)/2*Ipark^2*sin(2*gammaFilt);
        T1 = 1.5 * pp * Psi * Ipark * cos(gammaStar);
        T2 = 1.5 * pp * (Lq - Ld) / 2 * Ipark ^ 2 * sin(2 * gammaStar);
        torqueReq = T1 + T2;
        annotation (
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-98, -110}, {102, -146}}, lineColor = {0, 0, 127}, textString = "%name"), Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 26}, {100, -26}}, lineColor = {0, 0, 127}, textString = "MTPAa")}),
          Diagram(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2})),
          experiment(StartTime = 0, StopTime = 8, Tolerance = 0.0001, Interval = 0.0016));
      end MTPAa;

      model MTPAal "MTPA logic for an anisotropic PMSM machine with current limitation"
        // Non-Ascii Symbol to cause UTF-8 saving by Dymola: €
        parameter Real gain(unit = "Nm/A") = 5000 / (1.5 * Ipm * pp) "Current loop gain";
        parameter Modelica.SIunits.Current Ipm = 1.5 "Permanent magnet current";
        parameter Integer pp = 1 "Pole pairs";
        parameter Modelica.SIunits.Resistance Rs = 0.02 "Stator resistance (Ω)";
        parameter Modelica.SIunits.Inductance Ld = 0.4 "Basic direct-axis inductance (H)";
        parameter Modelica.SIunits.Inductance Lq = 1.1 "Basic quadrature-axis inductance (H)";
        parameter Modelica.SIunits.Voltage Umax = 100 "Max rms voltage per phase to the motor";
        parameter Modelica.SIunits.Current Ilim = 100 "nominal current (rms per phase)";
        Modelica.Blocks.Interfaces.RealInput torqueReq annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}}), iconTransformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealInput wMech annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}}), iconTransformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.RealOutput Id annotation (
          Placement(transformation(extent = {{100, 50}, {120, 70}}), iconTransformation(extent = {{100, 50}, {120, 70}})));
        Modelica.Blocks.Interfaces.RealOutput Iq annotation (
          Placement(transformation(extent = {{100, -70}, {120, -50}}), iconTransformation(extent = {{100, -70}, {120, -50}})));
        Modelica.Blocks.Interfaces.RealInput uDC "DC voltage" annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        MTPAa mTPAa(Ipm = Ipm, pp = pp, Rs = Rs, Ld = Ld, Lq = Lq, Umax = Umax) annotation (
          Placement(transformation(extent = {{6, -36}, {26, -16}})));
        Modelica.Blocks.Math.Feedback feedback annotation (
          Placement(visible = true, transformation(extent = {{38, 14}, {58, 34}}, rotation = 0)));
        Modelica.Blocks.Sources.Constant Ilim_(k = IlimPk) annotation (
          Placement(visible = true, transformation(origin = {48, 0}, extent = {{10, -10}, {-10, 10}}, rotation = -90)));
        Modelica.Blocks.Continuous.FirstOrder firstOrder(T = 0.01, k = gain) annotation (
          Placement(visible = true, transformation(extent = {{60, 50}, {40, 70}}, rotation = 0)));
        Modelica.Blocks.Nonlinear.Limiter limiter1(uMax = 1e99, uMin = 0) annotation (
          Placement(visible = true, transformation(origin = {6, 60}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
        Modelica.Blocks.Math.Add add1(k1 = -1) annotation (
          Placement(visible = true, transformation(origin = {-34, 8}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
        Modelica.Blocks.Continuous.FirstOrder firstOrder1(T = 0.01, k = 1) annotation (
          Placement(visible = true, transformation(extent = {{-74, 50}, {-54, 70}}, rotation = 0)));
        Modelica.Blocks.Logical.GreaterThreshold limiting(threshold = IlimPk / 1e6) annotation (
          Placement(visible = true, transformation(extent = {{-14, 18}, {6, 38}}, rotation = 0)));
      protected
        parameter Modelica.SIunits.Current IlimPk = sqrt(2) * Ilim "current limit (A peak)";
      equation
        connect(firstOrder1.y, add1.u2) annotation (
          Line(points = {{-53, 60}, {-40, 60}, {-40, 20}}, color = {0, 0, 127}));
        connect(firstOrder1.u, torqueReq) annotation (
          Line(points = {{-76, 60}, {-120, 60}}, color = {0, 0, 127}));
        connect(limiting.u, add1.u1) annotation (
          Line(points = {{-16, 28}, {-28, 28}, {-28, 20}}, color = {0, 0, 127}));
        connect(add1.y, mTPAa.torqueReq) annotation (
          Line(points = {{-34, -3}, {-34, -20}, {4, -20}}, color = {0, 0, 127}));
        connect(limiter1.y, add1.u1) annotation (
          Line(points = {{-5, 60}, {-28, 60}, {-28, 20}}, color = {0, 0, 127}));
        connect(firstOrder.y, limiter1.u) annotation (
          Line(points = {{39, 60}, {18, 60}}, color = {0, 0, 127}));
        connect(firstOrder.u, feedback.y) annotation (
          Line(points = {{62, 60}, {72, 60}, {72, 24}, {57, 24}}, color = {0, 0, 127}));
        connect(feedback.u1, mTPAa.Ipark) annotation (
          Line(points = {{40, 24}, {16, 24}, {16, -15}}, color = {0, 0, 127}));
        connect(Ilim_.y, feedback.u2) annotation (
          Line(points = {{48, 11}, {48, 16}}, color = {0, 0, 127}));
        connect(mTPAa.uDC, uDC) annotation (
          Line(points = {{4, -26}, {-68, -26}, {-68, 0}, {-120, 0}}, color = {0, 0, 127}));
        connect(mTPAa.wMech, wMech) annotation (
          Line(points = {{4, -32}, {4, -32}, {-34, -32}, {-34, -60}, {-120, -60}}, color = {0, 0, 127}));
        connect(mTPAa.Id, Id) annotation (
          Line(points = {{27, -20}, {27, -20}, {86, -20}, {86, 60}, {110, 60}}, color = {0, 0, 127}));
        connect(mTPAa.Iq, Iq) annotation (
          Line(points = {{27, -32}, {27, -32}, {86, -32}, {86, -60}, {110, -60}}, color = {0, 0, 127}));
        annotation (
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Text(extent = {{-100, 142}, {100, 106}}, lineColor = {0, 0, 127}, textString = "%name"), Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 24}, {100, -26}}, lineColor = {0, 0, 127}, textString = "MTPAal")}),
          Diagram(coordinateSystem(extent = {{-100, -80}, {100, 80}}, preserveAspectRatio = false)),
          experiment(StartTime = 0, StopTime = 8, Tolerance = 0.0001, Interval = 0.0016));
      end MTPAal;

      model FromPark "Semplice PMM con modello funzionale inverter"
        parameter Integer p "Number or pole pairs";
        Modelica.Electrical.Machines.SpacePhasors.Blocks.FromSpacePhasor fromSpacePhasor annotation (
          Placement(transformation(extent = {{60, 0}, {80, 20}})));
        Modelica.Electrical.Machines.SpacePhasors.Blocks.Rotator rotator annotation (
          Placement(transformation(extent = {{0, 6}, {20, 26}})));
        Modelica.Blocks.Routing.Multiplex2 multiplex2_1 annotation (
          Placement(transformation(extent = {{-40, 0}, {-20, 20}})));
        Modelica.Blocks.Interfaces.RealOutput y[3] annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Interfaces.RealInput Xd annotation (
          Placement(transformation(extent = {{-140, 40}, {-100, 80}}), iconTransformation(extent = {{-140, 40}, {-100, 80}})));
        Modelica.Blocks.Interfaces.RealInput Xq annotation (
          Placement(transformation(extent = {{-140, -80}, {-100, -40}}), iconTransformation(extent = {{-140, -80}, {-100, -40}})));
        Modelica.Blocks.Interfaces.RealInput phi annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {0, -120}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {0, -120})));
        Modelica.Blocks.Math.Gain gain(k = -p) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {10, -50})));
        Modelica.Blocks.Sources.Constant const annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {50, -30})));
      equation
        connect(multiplex2_1.y, rotator.u) annotation (
          Line(points = {{-19, 10}, {-10, 10}, {-10, 16}, {-2, 16}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(fromSpacePhasor.u, rotator.y) annotation (
          Line(points = {{58, 10}, {40, 10}, {40, 16}, {21, 16}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(fromSpacePhasor.y, y) annotation (
          Line(points = {{81, 10}, {94, 10}, {94, 0}, {110, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(multiplex2_1.u1[1], Xd) annotation (
          Line(points = {{-42, 16}, {-60, 16}, {-60, 60}, {-120, 60}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(multiplex2_1.u2[1], Xq) annotation (
          Line(points = {{-42, 4}, {-60, 4}, {-60, -60}, {-120, -60}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(rotator.angle, gain.y) annotation (
          Line(points = {{10, 4}, {10, -39}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(gain.u, phi) annotation (
          Line(points = {{10, -62}, {10, -120}, {0, -120}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(fromSpacePhasor.zero, const.y) annotation (
          Line(points = {{58, 2}, {50, 2}, {50, -19}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}})),
          experiment(StopTime = 5, Interval = 0.001),
          Documentation(info = "<html>
 <p><br/><b>Test example: Permanent magnet synchronous induction machine fed by a current source</b></p>


 <p><i><span style='color:red'>NOTA: la macchina ha Lmd=Lmq=0.3(2*pi*f) come definito internamente.</p>
 <i><span style='color:red'>E&apos; pertanto una macchina isotropa. la miglior maniera di controllarla, quindi, dovrebbe essere di mettere la corrente tutta sull&apos;asse q e mantenere a 0 la componente sull&apos;asse d.</p></i>


 <p><br/><br/>A synchronous induction machine with permanent magnets accelerates a quadratic speed dependent load from standstill. The rms values of d- and q-current in rotor fixed coordinate system are converted to threephase currents, and fed to the machine. The result shows that the torque is influenced by the q-current, whereas the stator voltage is influenced by the d-current.</p><p><br/><br/>Default machine parameters of model <i>SM_PermanentMagnet</i> are used. </p>
 </html>"),
          __Dymola_experimentSetupOutput,
          Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}}, preserveAspectRatio = false, initialScale = 0.1, grid = {2, 2}), graphics = {Rectangle(lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, 100}, {100, -100}}), Text(lineColor = {0, 0, 127}, extent = {{-96, 28}, {96, -26}}, textString = "P=>"), Text(lineColor = {0, 0, 255}, extent = {{-108, 150}, {102, 110}}, textString = "%name")}));
      end FromPark;

      model ToPark "Semplice PMM con modello funzionale inverter"
        parameter Integer p "number of pole pairs";
        Modelica.Electrical.Machines.SpacePhasors.Blocks.Rotator rotator annotation (
          Placement(transformation(extent = {{0, 0}, {20, 20}})));
        Modelica.Blocks.Interfaces.RealOutput y[2] annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Interfaces.RealInput X[3] annotation (
          Placement(transformation(extent = {{-140, -20}, {-100, 20}}), iconTransformation(extent = {{-140, -20}, {-100, 20}})));
        Modelica.Blocks.Interfaces.RealInput phi annotation (
          Placement(transformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {10, -110}), iconTransformation(extent = {{-20, -20}, {20, 20}}, rotation = 90, origin = {0, -120})));
        Modelica.Electrical.Machines.SpacePhasors.Blocks.ToSpacePhasor toSpacePhasor annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-30, 10})));
        Modelica.Blocks.Math.Gain gain(k = p) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {10, -42})));
      equation
        connect(toSpacePhasor.y, rotator.u) annotation (
          Line(points = {{-19, 10}, {-2, 10}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(rotator.y, y) annotation (
          Line(points = {{21, 10}, {66, 10}, {66, 0}, {110, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(toSpacePhasor.u, X) annotation (
          Line(points = {{-42, 10}, {-82, 10}, {-82, 0}, {-120, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(gain.y, rotator.angle) annotation (
          Line(points = {{10, -31}, {10, -2}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(gain.u, phi) annotation (
          Line(points = {{10, -54}, {10, -110}}, color = {0, 0, 127}, smooth = Smooth.None));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics),
          experiment(StopTime = 5, Interval = 0.001),
          Documentation(info = "<html>
<p><br/><b>Test example: Permanent magnet synchronous induction machine fed by a current source</b></p>


<p><i><span style='color:red'>NOTA: la macchina ha Lmd=Lmq=0.3(2*pi*f) come definito internamente.</p>
<i><span style='color:red'>E&apos; pertanto una macchina isotropa. la miglior maniera di controllarla, quindi, dovrebbe essere di mettere la corrente tutta sull&apos;asse q e mantenere a 0 la componente sull&apos;asse d.</p></i>


<p><br/><br/>A synchronous induction machine with permanent magnets accelerates a quadratic speed dependent load from standstill. The rms values of d- and q-current in rotor fixed coordinate system are converted to threephase currents, and fed to the machine. The result shows that the torque is influenced by the q-current, whereas the stator voltage is influenced by the d-current.</p><p><br/><br/>Default machine parameters of model <i>SM_PermanentMagnet</i> are used. </p>
</html>"),__Dymola_experimentSetupOutput,
          Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-96, 32}, {96, -22}}, lineColor = {0, 0, 127}, textString = "=>P"), Text(extent = {{-106, 144}, {104, 106}}, lineColor = {0, 0, 255}, textString = "%name")}));
      end ToPark;

      block GenSines "Generates three-phase sine waves"
        import Modelica.Constants.pi;
        Modelica.Blocks.Interfaces.RealInput Westar annotation (
          Placement(transformation(extent = {{-140, 28}, {-100, 68}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 0, origin = {-113, 59})));
        Modelica.Blocks.Interfaces.RealOutput y[3] annotation (
          Placement(transformation(extent = {{100, -10}, {120, 10}}), iconTransformation(extent = {{100, -10}, {120, 10}})));
        Modelica.Blocks.Interfaces.RealInput Ustar "RMS phase" annotation (
          Placement(transformation(extent = {{-140, -60}, {-100, -20}}), iconTransformation(extent = {{-13, -13}, {13, 13}}, rotation = 0, origin = {-113, -59})));
        Modelica.Blocks.Math.Add add1[3] annotation (
          Placement(transformation(extent = {{0, 38}, {20, 58}})));
        Modelica.Blocks.Math.Sin sin[3] annotation (
          Placement(transformation(extent = {{34, 38}, {54, 58}})));
        Modelica.Blocks.Continuous.Integrator integrator annotation (
          Placement(transformation(extent = {{-72, 38}, {-52, 58}})));
        Modelica.Blocks.Routing.Replicator replicator(nout = 3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {60, 8})));
        Modelica.Blocks.Math.Product product[3] annotation (
          Placement(transformation(extent = {{72, 28}, {92, 48}})));
        Modelica.Blocks.Math.Gain ToPeak(k = sqrt(2)) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {60, -22})));
        Modelica.Blocks.Sources.Constant phase[3](k = 2 * pi / 3 * {0, -1, 1}) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 90, origin = {-10, 8})));
        Modelica.Blocks.Routing.Replicator replicator1(nout = 3) annotation (
          Placement(transformation(extent = {{-10, -10}, {10, 10}}, rotation = 0, origin = {-30, 48})));
      equation
        connect(sin.u, add1.y) annotation (
          Line(points = {{32, 48}, {21, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(product.y, y) annotation (
          Line(points = {{93, 38}, {102, 38}, {102, 0}, {110, 0}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(product.u2, replicator.y) annotation (
          Line(points = {{70, 32}, {60, 32}, {60, 19}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(ToPeak.y, replicator.u) annotation (
          Line(points = {{60, -11}, {60, -4}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(sin.y, product.u1) annotation (
          Line(points = {{55, 48}, {62, 48}, {62, 44}, {70, 44}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(add1.u1, replicator1.y) annotation (
          Line(points = {{-2, 54}, {-10, 54}, {-10, 48}, {-19, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(add1.u2, phase.y) annotation (
          Line(points = {{-2, 42}, {-10, 42}, {-10, 19}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(replicator1.u, integrator.y) annotation (
          Line(points = {{-42, 48}, {-51, 48}}, color = {0, 0, 127}, smooth = Smooth.None));
        connect(integrator.u, Westar) annotation (
          Line(points = {{-74, 48}, {-82, 48}, {-88, 48}, {-120, 48}}, color = {0, 0, 127}));
        connect(ToPeak.u, Ustar) annotation (
          Line(points = {{60, -34}, {60, -34}, {60, -40}, {-120, -40}}, color = {0, 0, 127}));
        annotation (
          Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -80}, {100, 80}})),
          Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, 144}, {98, 106}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, textString = "%name"), Line(points = {{-4, 28}, {8, 48}, {28, 48}, {48, 8}, {70, 8}, {82, 28}}, color = {0, 0, 0}), Line(points = {{-6, 4}, {6, 24}, {26, 24}, {46, -16}, {68, -16}, {80, 4}}, color = {0, 0, 0}), Line(points = {{-8, -16}, {4, 4}, {24, 4}, {44, -36}, {66, -36}, {78, -16}}, color = {0, 0, 0}), Rectangle(extent = {{-88, 10}, {-60, -4}}, lineColor = {0, 0, 0}), Polygon(points = {{-60, 18}, {-34, 4}, {-60, -10}, {-60, 18}}, lineColor = {0, 0, 0})}),
          Documentation(info = "<html>
<p>This class produces a three-phase voltage system to variable-frequency control of an asynchronous motor.</p>
<p>The output voltages constitute a three-phase system of quasi-sinusoidal shapes, created according to the following equations:</p>
<p>Wel=Wmecc*PolePairs+DeltaWel</p>
<p>U=U0+(Un-U0)*(Wel)/Wnom</p>
<p>where:</p>
<p><ul>
<li>U0, Un U, are initial, nominal actual voltage amplitudes</li>
<li>Wmecc, Wel are machine (mechanical) and supply (electrical) angular speeds</li>
<li>PolePairs are the number of machine pole pairs</li>
<li>DeltaWel is an input variable and depends on the desired torque</li>
</ul></p>
</html>"));
      end GenSines;
      annotation (
        Icon(graphics = {Ellipse(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 0.5, extent = {{-100, 100}, {100, -100}}, endAngle = 360), Text(origin = {0, -1}, lineColor = {28, 108, 200}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, lineThickness = 0.5, extent = {{-100, 61}, {100, -61}}, textString = "S", textStyle = {TextStyle.Bold})}));
    end SMArelated;
    annotation (
      Icon(graphics={  Ellipse(fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid,
              lineThickness =                                                                                0.5, extent = {{-100, 100}, {98, -100}}, endAngle = 360), Text(origin = {0, 2.66666}, lineColor = {28, 108, 200}, fillColor = {255, 255, 255},
              fillPattern =                                                                                                                                                                                                        FillPattern.Solid,
              lineThickness =                                                                                                                                                                                                        0.5, extent = {{-100, 63.3333}, {100, -66.6667}}, textString = "D", textStyle = {TextStyle.Bold})}));
  end ElectricDrives;
  annotation (
    uses(Modelica(version = "3.2.3")),
    Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics={  Polygon(points = {{-60, 16}, {78, 16}, {94, 0}, {96, -16}, {-98, -16}, {-90, 0}, {-76, 12}, {-60, 16}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {0, 0, 255},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{-70, -4}, {-30, -40}}, lineColor = {95, 95, 95}, fillColor = {95, 95, 95},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{34, -6}, {74, -42}}, lineColor = {95, 95, 95}, fillColor = {95, 95, 95},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Polygon(points = {{-54, 16}, {-18, 46}, {46, 46}, {74, 16}, {-54, 16}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {0, 0, 255},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{-86, -6}, {-92, 4}}, lineColor = {0, 0, 0}, fillColor = {255, 255, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{98, -10}, {92, -4}}, lineColor = {0, 0, 0}, fillColor = {255, 0, 0},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Polygon(points = {{-46, 20}, {-20, 42}, {16, 42}, {14, 20}, {-46, 20}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Polygon(points = {{22, 42}, {42, 42}, {60, 20}, {20, 20}, {22, 42}}, lineColor = {0, 0, 0}, smooth = Smooth.None, fillColor = {255, 255, 255},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{-60, -12}, {-40, -30}}, lineColor = {95, 95, 95}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid), Ellipse(extent = {{44, -14}, {64, -32}}, lineColor = {95, 95, 95}, fillColor = {215, 215, 215},
            fillPattern =                                                                                                                                                                                                        FillPattern.Solid)}),
    Documentation(info = "<html>
<p>Library containing models of components, subsystems and full vehicle examples for simulation of electric and Hybrid vehicular power trains.</p>
<p>A general description of the library composition and on how to use it effectively is in the companion paper:</p>
<p>M. Ceraolo &quot;Modelica Electric and hybrid power trains library&quot; submitted for publication at the 11th International Modelica Conference, 2015, September 21-23, Palais des congr&egrave;s de Versailles, 23-23 September, France</p>
</html>"));
end EHPTlib;
