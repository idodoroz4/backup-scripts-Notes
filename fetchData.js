useEffect(() => {
    let mounted = true;
    const fetchAndSetDefaultConfiguration = async () => {
      try {
        const { data } = await getClustersDefaultConfiguration();
        if (mounted) {
          setDefaultConfiguration(data);
        }
      } catch (e) {
        handleApiError(e, () =>
          addAlert({
            title: 'Failed to retrieve the default configuration',
            message: getErrorMessage(e),
          }),
        );
      }
    };
    fetchAndSetDefaultConfiguration();

    return () => {
      mounted = false;
    };
  }, []); // eslint-disable-line react-hooks/exhaustive-deps
