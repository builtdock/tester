
import os.path
import re

from buildbot.steps.transfer import DirectoryUpload


class TransferCoverageResults(DirectoryUpload):

    report_re = re.compile(
        r"""Coverage Report:\s+<[a-z '"=_]+>(?P<coverage>\d+%)</[a-z]+>""")

    def finished(self, result):
        result = DirectoryUpload.finished(self, result)
        buildnumber = self.getProperty('buildnumber')
        coverage_index = os.path.expanduser(
            '/app/master/public_html/htmlcov-%d/index.html' % (buildnumber))
        with open(coverage_index) as coverage_file:
            m = self.report_re.search(coverage_file.read())
        self.descriptionDone = '%s test coverage' % m.group(1)
        self.step_status.setText(self.descriptionDone)
        coverage_url = '/htmlcov-%d/' % (buildnumber)
        self.addURL('full report', coverage_url)
        return result
