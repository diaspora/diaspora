ConfigurationLoadingTest::MockConfig.instance(:must_exist).load do
  ping! :custom
end
