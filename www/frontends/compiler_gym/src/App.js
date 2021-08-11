/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import React, { useEffect, useState } from "react";
import "./assets/scss/custom.scss";
import ApiService from "./api/ApiService";
import ApiContext from "./context/ApiContext";
import ThemeContext from "./context/ThemeContext";
import SplashPage from "./components/Pages/SplashPage";
import MainNavbar from "./components/Navbars/MainNavbar";
import PanelsContainer from "./components/PanelsContainer";
import ControlsContainer from "./components/Sections/ControlsContainer";
import ObservationsContainer from "./components/Sections/ObservationsContainer";

const api = new ApiService("http://18.118.146.0:5000/");
const initialSettings = {
  reward: "IrInstructionCountOz",
  benchmark: "benchmark://cbench-v1/qsort",
};

function App() {
  const [compilerGym, setCompilerGym] = useState({});
  const [session, setSession] = useState({});
  const [darkTheme, setDarkTheme] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  /*
   * Start a new session when component mounts in the browser.
   * It collects CompilerGym variables
   */
  useEffect(() => {
    const fetchData = async () => {
      try {
        const options = await api.getEnvOptions();
        const initSession = await api.startSession(
          initialSettings.reward,
          initialSettings.benchmark
        );
        console.log(initSession);
        setCompilerGym(options);
        setSession(initSession);
        setIsLoading(false);
      } catch (err) {
        console.log(err);
      }
    };

    setIsLoading(true);
    fetchData();
    return () => {};
  }, []);

  useEffect(() => {
    window.addEventListener("beforeunload", handleTabClosing);
    return () => {
      window.removeEventListener("beforeunload", handleTabClosing);
    };
  });

  const handleTabClosing = () => {
    api.closeSession(session.session_id).then(
      (result) => {
        console.log(result);
      },
      (error) => {
        console.log(error);
      }
    );
  };

  const submitStep = (stepIDs) => {
    api.getSteps(session.session_id, stepIDs).then(
      (result) => {
        setSession({
          ...session,
          states: [...session.states, ...result.states],
        });
      },
      (error) => {
        console.log(error);
      }
    );
  };

  const toggleTheme = () => {
    setDarkTheme(!darkTheme);
  };

  if (isLoading) return <SplashPage />;

  return (
    <>
      <ApiContext.Provider
        value={{
          api: api,
          compilerGym: compilerGym,
          session: session,
          setSession,
          submitStep,
        }}
      >
        <ThemeContext.Provider
          value={{ darkTheme: darkTheme, toggleTheme: toggleTheme }}
        >
          <div className="main-content">
            <MainNavbar />
            <PanelsContainer
              left={<ControlsContainer />}
              right={<ObservationsContainer />}
            />
          </div>
        </ThemeContext.Provider>
      </ApiContext.Provider>
    </>
  );
}

export default App;
